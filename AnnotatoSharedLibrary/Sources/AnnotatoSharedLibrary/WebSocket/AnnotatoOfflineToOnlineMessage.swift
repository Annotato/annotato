import Foundation

public final class AnnotatoOfflineToOnlineMessage: Codable {
    public private(set) var type = AnnotatoMessageType.offlineToOnline
    public let senderId: String
    public let mergeStrategy: AnnotatoOfflineToOnlineMergeStrategy
    public let lastOnlineAt: Date
    public let documents: [Document]
    public let annotations: [Annotation]

    public required init(
        senderId: String,
        mergeStrategy: AnnotatoOfflineToOnlineMergeStrategy,
        lastOnlineAt: Date,
        documents: [Document] = [],
        annotations: [Annotation] = []
    ) {
        self.senderId = senderId
        self.mergeStrategy = mergeStrategy
        self.lastOnlineAt = lastOnlineAt
        self.documents = documents
        self.annotations = annotations
    }
}

extension AnnotatoOfflineToOnlineMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoOfflineToOnlineMessage(senderId: \(senderId), type: \(type), mergeStrategy: \(mergeStrategy), " +
        "lastOnlineAt: \(lastOnlineAt), documents: \(documents), annotations: \(annotations))"
    }
}
