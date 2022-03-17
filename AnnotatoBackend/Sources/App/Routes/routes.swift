import Vapor
import Fluent
import AnnotatoSharedLibrary

func routes(_ app: Application) throws {
    app.get { _ in
        "AnnotatoBackend up and running!"
    }

    app.group("documents", configure: documentsRouter)

    app.get("test") { _ -> String in
        let testDocument = Document(name: "Test Document",
                                    ownerId: "user", baseFileUrl: "path/to/document")
        let testDocumentEntity = DocumentEntity.fromModel(testDocument)
        _ = testDocumentEntity.save(on: app.db)

        print(testDocumentEntity)

        let testAnnotation = Annotation(origin: .zero, width: .infinity,
                                        ownerId: "user", documentId: testDocumentEntity.id!)
        let testAnnotationEntity = AnnotationEntity.fromModel(testAnnotation)
        _ = testAnnotationEntity.save(on: app.db)

        print(testAnnotationEntity)
        print(testAnnotationEntity.$document.id)

        let testAnnotationText = AnnotationText(type: .markdown, content: "Content",
                                                height: 100, annotationId: testAnnotationEntity.id!)
        let testAnnotationTextEntity = AnnotationTextEntity.fromModel(testAnnotationText)
        _ = testAnnotationTextEntity.save(on: app.db)

        print(testAnnotationTextEntity)
        print(testAnnotationTextEntity.$annotation.id)

        print(testDocumentEntity.$annotations)
        print(testAnnotationEntity.$annotationTextEntities)

        return "done"
    }
}
