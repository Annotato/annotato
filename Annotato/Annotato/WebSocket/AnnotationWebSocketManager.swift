import Foundation
import AnnotatoSharedLibrary

class AnnotationWebSocketManager: ObservableObject {
    @Published private(set) var newAnnotation: Annotation?
    @Published private(set) var readAnnotation: Annotation?
    @Published private(set) var updatedAnnotation: Annotation?
    @Published private(set) var deletedAnnotation: Annotation?

    func handleResponseData(data: Data) {
        do {
            AnnotatoLogger.info("Handling annotation response data...")

            let message = try JSONDecoder().decode(AnnotatoCrudAnnotationMessage.self, from: data)
            let annotation = message.annotation

            switch message.subtype {
            case .createAnnotation:
                newAnnotation = annotation
                AnnotatoLogger.info("Annotation was created. \(annotation)")
            case .readAnnotation:
                readAnnotation = annotation
                AnnotatoLogger.info("Annotation was read. \(annotation)")
            case .updateAnnotation:
                updatedAnnotation = annotation
                AnnotatoLogger.info("Annotation was updated. \(annotation)")
            case .deleteAnnotation:
                deletedAnnotation = annotation
                AnnotatoLogger.info("Annotation was deleted. \(annotation)")
            }

        } catch {
            AnnotatoLogger.error(
                "When handling reponse data. \(error.localizedDescription).",
                context: "AnnotationWebSocketManager:handleResponseData:"
            )
        }
    }
}
