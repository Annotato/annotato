import Foundation

public class JSONCustomEncoder: JSONEncoder {
    override public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(value)
    }
}
