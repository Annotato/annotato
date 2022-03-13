import Vapor
import AnnotatoSharedLibrary // TODO: Remove after testing

func routes(_ app: Application) throws {
    app.get { _ in
        "It works!"
    }

    app.get("hello") { _ -> String in
        "Hello, world!"
    }

    // TODO: Remove after testing
    /// For testing only: Creates a document and returns the id of the created document as the response
    app.get("test_documents") { _ -> String in
        let testDocument = Document(name: "Test Document", ownerId: UUID(), baseFileUrl: "path/to/document")
        let testDocumentEntity = DocumentEntity.fromModel(testDocument)
        testDocumentEntity.save(on: app.db)

        return String(describing: testDocumentEntity.id)
    }
}
