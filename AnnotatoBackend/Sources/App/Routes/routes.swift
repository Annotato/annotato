import Vapor
import Fluent
import AnnotatoSharedLibrary

func routes(_ app: Application) throws {
    app.get { _ in
        "AnnotatoBackend up and running!"
    }

    app.group("documents", configure: documentsRouter)

    app.get("test") { _ -> String in
        // DOCUMENT
        let testDocument = Document(name: "Test Document",
                                    ownerId: "user", baseFileUrl: "path/to/document")
        let testDocumentEntity = DocumentEntity.fromModel(testDocument)
        _ = testDocumentEntity.save(on: app.db).map { _ in
            // ANNOTATION
            let testAnnotation = Annotation(origin: .zero, width: .infinity,
                                            ownerId: "user", documentId: testDocumentEntity.id!)
            let testAnnotationEntity = AnnotationEntity.fromModel(testAnnotation)
            _ = testAnnotationEntity.save(on: app.db).map { _ in
                // ANNOTATION TEXT
                let testAnnotationText = AnnotationText(type: .markdown, content: "Content",
                                                        height: 100.0, annotationId: testAnnotationEntity.id!)
                let testAnnotationTextEntity = AnnotationTextEntity.fromModel(testAnnotationText)
                _ = testAnnotationTextEntity.save(on: app.db)


                print("DOCUMENT: ", testDocumentEntity)
                print("ANNOTATION: ", testAnnotationEntity)
                print("ANNOTATION PARENT: ", testAnnotationEntity.$document.id)
                print("ANNOTATION TEXT: ", testAnnotationTextEntity)
                print("ANNOTATION TEXT PARENT: ", testAnnotationTextEntity.$annotation.id)
                print("DOCUMENT CHILDREN: ", testDocumentEntity.$annotations)
                print("ANNOTATION CHILDREN: ", testAnnotationEntity.$annotationTextEntities)
            }
        }

        return "done"
    }
}
