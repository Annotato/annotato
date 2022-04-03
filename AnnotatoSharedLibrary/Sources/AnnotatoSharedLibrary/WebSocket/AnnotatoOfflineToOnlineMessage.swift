import Foundation

public class AnnotatoOfflineToOnlineMessage: Codable {
    public private(set) var type = AnnotatoMessageType.offlineToOnline
    public let mergeStrategy: AnnotatoOfflineToOnlineMergeStrategy
    public let lastOnlineAt: Date
    public let documents: [Document]
    public let annotations: [Annotation]

    public required init(
        mergeStrategy: AnnotatoOfflineToOnlineMergeStrategy,
        lastOnlineAt: Date,
        documents: [Document] = [],
        annotations: [Annotation] = []
    ) {
        self.mergeStrategy = mergeStrategy
        self.lastOnlineAt = lastOnlineAt
        self.documents = documents
        self.annotations = annotations
    }
}

extension AnnotatoOfflineToOnlineMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoOfflineToOnlineMessage(type: \(type), mergeStrategy: \(mergeStrategy), " +
        "lastOnlineAt: \(lastOnlineAt), documents: \(documents), annotations: \(annotations))"
    }
}
