import Foundation
import AnnotatoSharedLibrary

struct DocumentsAPI {
    private static let documentsUrl = "\(BaseAPI.baseAPIUrl)/documents"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
    }

    func getDocuments(userId: String) async -> [Document]? {
        do {
            let responseData = try await httpService.get(url: DocumentsAPI.documentsUrl,
                                                         params: ["userId": userId])
            return try JSONDecoder().decode([Document].self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching documents: \(error.localizedDescription)")
            return nil
        }
    }

    func getDocument(documentId: UUID) async -> Document? {
        do {
            let responseData = try await httpService.get(url: "\(DocumentsAPI.documentsUrl)/\(documentId)")
            return try JSONDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching document: \(error.localizedDescription)")
            return nil
        }
    }

    func createDocument(document: Document) async -> Document? {
        guard let requestData = encodeDocument(document) else {
            AnnotatoLogger.error("Document was not created",
                                 context: "DocumentsAPI::createDocument")
            return nil
        }

        do {
            let responseData = try await httpService.post(url: DocumentsAPI.documentsUrl, data: requestData)
            return try JSONDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching document: \(error.localizedDescription)")
            return nil
        }
    }

    func updateDocument(document: Document) async -> Document? {
        guard let documentId = document.id else {
            AnnotatoLogger.error("\(document) has a nil ID and cannot be updated",
                                 context: "DocumentsAPI::updateDocument")
            return nil
        }

        guard let requestData = encodeDocument(document) else {
            AnnotatoLogger.error("Document was not updated",
                                 context: "DocumentsAPI::createDocument")
            return nil
        }

        do {
            let responseData = try await httpService.put(url: "\(DocumentsAPI.documentsUrl)/\(documentId)",
                                                         data: requestData)
            return try JSONDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When updating document: \(error.localizedDescription)")
            return nil
        }
    }

    func deleteDocument(documentId: UUID) async -> Document? {
        do {
            let responseData = try await httpService.delete(url: "\(DocumentsAPI.documentsUrl)/\(documentId)")
            return try JSONDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When deleting document: \(error.localizedDescription)")
            return nil
        }
    }

    private func encodeDocument(_ document: Document) -> Data? {
        do {
            let data = try JSONEncoder().encode(document)
            return data
        } catch {
            AnnotatoLogger.error("Could not encode Document into JSON",
                                 context: "DocumentsAPI::encodeDocument")
            return nil
        }
    }
}
