import Foundation
import AnnotatoSharedLibrary

class AnnotationWebSocketManager: ObservableObject {
    @Published private(set) var newAnnotation: Annotation?
    @Published private(set) var readAnnotation: Annotation?
    @Published private(set) var updatedAnnotation: Annotation?
    @Published private(set) var deletedAnnotation: Annotation?

    func handleResponseData(data: Data) {
        do {
            let message = try JSONDecoder().decode(AnnotatoCrudAnnotationMessage.self, from: data)
            let annotation = message.annotation

            switch message.subtype {
            case .createAnnotation:
                newAnnotation = annotation
            case .readAnnotation:
                readAnnotation = annotation
            case .updateAnnotation:
                updatedAnnotation = annotation
            case .deleteAnnotation:
                deletedAnnotation = annotation
            }

        } catch {
            AnnotatoLogger.error(
                "When handling reponse data. \(error.localizedDescription).",
                context: "AnnotationWebSocketManager:handleResponseData:"
            )
        }
    }
}
