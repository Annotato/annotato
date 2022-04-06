import Foundation
import AnnotatoSharedLibrary

class AnnotationWebSocketManager: ObservableObject {
    @Published private(set) var newAnnotation: Annotation?
    @Published private(set) var updatedAnnotation: Annotation?
    @Published private(set) var deletedAnnotation: Annotation?

    func handleResponseData(data: Data) {
        do {
            AnnotatoLogger.info("Handling annotation response data...")

            let message = try JSONCustomDecoder().decode(AnnotatoCudAnnotationMessage.self, from: data)
            let annotation = message.annotation
            let senderId = message.senderId

            // Defensive resets
            newAnnotation = nil
            updatedAnnotation = nil
            deletedAnnotation = nil

            Task {
                _ = await LocalPersistenceManager.shared.annotations
                    .createOrUpdateAnnotation(annotation: annotation)
            }

            guard senderId != AnnotatoAuth().currentUser?.uid else {
                return
            }

            switch message.subtype {
            case .createAnnotation:
                newAnnotation = annotation
                AnnotatoLogger.info("Annotation was created. \(annotation)")
            case .updateAnnotation:
                updatedAnnotation = annotation
                AnnotatoLogger.info("Annotation was updated. \(annotation)")
            case .deleteAnnotation:
                deletedAnnotation = annotation
                AnnotatoLogger.info("Annotation was deleted. \(annotation)")
            }
        } catch {
            AnnotatoLogger.error(
                "When handling response data. \(error.localizedDescription).",
                context: "AnnotationWebSocketManager::handleResponseData"
            )
        }
    }
}
