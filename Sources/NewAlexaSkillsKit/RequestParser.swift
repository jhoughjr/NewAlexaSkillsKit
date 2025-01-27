import Foundation

public protocol RequestParser: AnyObject {
    var json: Any {get set}
    
    func update(withContentsOf url: URL) throws
    func update(with data: Data) throws
    
    func parseSession() -> Session?
    func parseRequestType() -> RequestType?
    func parseLaunchRequest() -> LaunchRequest?
    func parseIntentRequest() -> IntentRequest?
    func parseSessionEndedRequest() -> SessionEndedRequest?
}

public extension RequestParser {
    func update(withContentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        try update(with: data)
    }
    
    func update(with data: Data) throws {
        json = try JSONSerialization.jsonObject(with: data)
    }
}
