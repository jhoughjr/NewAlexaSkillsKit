import Foundation
import NewAlexaSkillsKit
import XCTest

private class FakeRequestHandler: RequestHandler {
    var handleLaunchCalled = false
    var handleIntentCalled = false
    var handleSessionEndedCalled = false
    
    func handleLaunch(request: LaunchRequest, session: Session, next: @escaping (StandardResult) -> ()) {
        handleLaunchCalled = true
        next(.success((standardResponse: StandardResponse(), sessionAttributes: [String: Any]())))
    }
    
    func handleIntent(request: IntentRequest, session: Session, next: @escaping (StandardResult) -> ()) {
        handleIntentCalled = true
        next(.success((standardResponse: StandardResponse(), sessionAttributes: [String: Any]())))
    }
    
    func handleSessionEnded(request: SessionEndedRequest, session: Session, next: @escaping (VoidResult) -> ()) {
        handleSessionEndedCalled = true
        next(.voidSuccess)
    }
}

private class FakeRequestParser: RequestParser {
    public var json: Any =  [:]
    public var requestType = RequestType.launch
    public var throwsOnUpdate = false

    func parseSession() -> Session? {
        return Session(isNew: false, sessionId: "", application: Application(applicationId: ""), attributes: [:], user: User(userId: ""))
    }
    
    func parseRequestType() -> RequestType? {
        return requestType
    }
    
    func parseLaunchRequest() -> LaunchRequest? {
        return LaunchRequest(request: Request(requestId: "", timestamp: Date(), locale: Locale(identifier: "")))
    }
    
    func parseIntentRequest() -> IntentRequest? {
        return IntentRequest(request: Request(requestId: "", timestamp: Date(), locale: Locale(identifier: "")), intent: Intent(name: ""))
    }
    
    func parseSessionEndedRequest() -> SessionEndedRequest? {
        return SessionEndedRequest(request: Request(requestId: "", timestamp: Date(), locale: Locale(identifier: "")), reason: Reason.unknown)
    }
    
    public func update(with data: Data) throws {
        if throwsOnUpdate {
            struct Error: Swift.Error {}
            throw Error()
        }
    }
}

private func createFilePath(for fileName: String) -> URL {
    return URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent(fileName)
}

class RequestDispatcherTests: XCTestCase {
    static let allTests = [
        ("testDispatchAsyncErrorParsingRequest", testDispatchAsyncErrorParsingRequest),
        ("testDispatchAsyncIntent", testDispatchAsyncIntent)
    ]
    
    private var requestHandler: FakeRequestHandler!
    private var requestParser: FakeRequestParser!
    var requestDispatcher: RequestDispatcher!
        
    override func setUp() {
        super.setUp()
        
        requestHandler = FakeRequestHandler()
        requestParser = FakeRequestParser()
        requestDispatcher = RequestDispatcher(requestHandler: requestHandler, requestParser: requestParser)
    }
    
    func testDispatchAsyncErrorParsingRequest() {
        requestParser.throwsOnUpdate = true
        let testExpectation = expectation(description: #function)
        requestDispatcher.dispatch(data: Data()) { response in
            switch response {
            case .success:
                XCTFail()
            case .failure:
                break
            case .voidSuccess:
                XCTFail()
            }
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(requestHandler.handleLaunchCalled)
        XCTAssertFalse(requestHandler.handleIntentCalled)
        XCTAssertFalse(requestHandler.handleSessionEndedCalled)
    }
    
    func testDispatchAsyncLaunch() throws {
        requestParser.requestType = .launch
        let testExpectation = expectation(description: #function)
        requestDispatcher.dispatch(data: Data()) { response in
            switch response {
            case .success:
                break
            case .voidSuccess:
                break
            case .failure:
                XCTFail()
            }
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(requestHandler.handleLaunchCalled)
        XCTAssertFalse(requestHandler.handleIntentCalled)
        XCTAssertFalse(requestHandler.handleSessionEndedCalled)
    }
    
    func testDispatchAsyncIntent() throws {
        requestParser.requestType = .intent
        let testExpectation = expectation(description: #function)
        requestDispatcher.dispatch(data: Data()) { response in
            switch response {
            case .success:
                break
            case .voidSuccess:
                break
            case .failure:
                XCTFail()
            }
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(requestHandler.handleLaunchCalled)
        XCTAssertTrue(requestHandler.handleIntentCalled)
        XCTAssertFalse(requestHandler.handleSessionEndedCalled)
    }
    
    func testDispatchAsyncSessionEnded() throws {
        requestParser.requestType = .sessionEnded
        let testExpectation = expectation(description: #function)
        requestDispatcher.dispatch(data: Data()) { response in
            switch response {
            case .success:
                break
            case .voidSuccess:
                break
            case .failure:
               break
            }
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(requestHandler.handleLaunchCalled)
        XCTAssertFalse(requestHandler.handleIntentCalled)
        XCTAssertTrue(requestHandler.handleSessionEndedCalled)
    }
}
