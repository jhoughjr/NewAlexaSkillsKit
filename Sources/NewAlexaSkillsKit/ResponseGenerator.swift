import Foundation

public protocol ResponseGenerator: AnyObject {
    var standardResponse: StandardResponse? {get set}
    var sessionAttributes: [String: Any] {get set}
    
    func update(standardResponse: StandardResponse?, sessionAttributes: [String: Any])
    
    func generateJSONObject() -> [String: Any]
    func generateJSON(options: JSONSerialization.WritingOptions) throws -> Data
}

public extension ResponseGenerator {
    func update(standardResponse: StandardResponse?, sessionAttributes: [String: Any]) {
        self.standardResponse = standardResponse
        self.sessionAttributes = sessionAttributes
    }
    
    func generateJSON(options: JSONSerialization.WritingOptions = []) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: generateJSONObject(), options: options)
        return data
    }
}
