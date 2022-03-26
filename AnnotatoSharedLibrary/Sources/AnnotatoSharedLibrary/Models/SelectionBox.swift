import Foundation
import Combine
import CoreGraphics

public final class SelectionBox: Codable, ObservableObject {
    private(set) var id: UUID
    public private(set) var startPoint: CGPoint
    @Published public private(set) var endPoint: CGPoint

    public required init(startPoint: CGPoint, endPoint: CGPoint, id: UUID? = nil) {
        self.id = id ?? UUID()
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    public func setEndPoint(to newEndPoint: CGPoint) {
        endPoint = newEndPoint
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case startPoint
        case endPoint
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startPoint = try container.decode(CGPoint.self, forKey: .startPoint)
        endPoint = try container.decode(CGPoint.self, forKey: .endPoint)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startPoint, forKey: .startPoint)
        try container.encode(endPoint, forKey: .endPoint)
    }
}

extension SelectionBox: CustomStringConvertible {
    public var description: String {
        "SelectionBox(id: \(id), startPoint: \(startPoint), endPoint: \(endPoint)"
    }
}
