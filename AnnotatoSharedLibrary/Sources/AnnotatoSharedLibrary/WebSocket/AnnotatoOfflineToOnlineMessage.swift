public class AnnotatoOfflineToOnlineMessage: Codable {
    public var type = AnnotatoMessageType.offlineToOnline
    public let mergeStrategy: AnnotatoOfflineToOnlineMergeStrategy
    public let documents: [Document]
    public let annotations: [Annotation]

    public required init(
        mergeStrategy: AnnotatoOfflineToOnlineMergeStrategy,
        documents: [Document] = [],
        annotations: [Annotation] = []
    ) {
        self.mergeStrategy = mergeStrategy
        self.documents = documents
        self.annotations = annotations
    }
}

extension AnnotatoOfflineToOnlineMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnnotatoOfflineToOnlineMessage(type: \(type), mergeStrategy: \(mergeStrategy), documents: \(documents), annotations: \(annotations))"
    }
}
