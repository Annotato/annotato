import Foundation

public class JSONDateDecoder: JSONDecoder {
    override public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(type, from: data)
    }
}
