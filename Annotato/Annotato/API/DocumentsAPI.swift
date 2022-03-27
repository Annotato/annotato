import Foundation
import AnnotatoSharedLibrary

struct DocumentsAPI {
    private static let documentsUrl = "\(BaseAPI.baseAPIUrl)/documents"
    private static let sharedDocumentsUrl = "\(documentsUrl)/shared"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
    }

    // MARK: LIST OWN
    func getOwnDocuments(userId: String) async -> [Document]? {
        do {
            let responseData = try await httpService.get(url: DocumentsAPI.documentsUrl,
                                                         params: ["userId": userId])
            return try JSONDecoder().decode([Document].self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching documents: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: LIST SHARED
    func getSharedDocuments(userId: String) async -> [Document]? {
        do {
            let responseData = try await httpService.get(url: DocumentsAPI.sharedDocumentsUrl,
                                                         params: ["userId": userId])
            return try JSONDecoder().decode([Document].self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching documents: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: READ
    func getDocument(documentId: UUID) async -> Document? {
        do {
            let responseData = try await httpService.get(url: "\(DocumentsAPI.documentsUrl)/\(documentId)")
            return try JSONDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching document: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: CREATE
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
            AnnotatoLogger.error("When creating document: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: UPDATE
    func updateDocument(document: Document) async -> Document? {
        guard let requestData = encodeDocument(document) else {
            AnnotatoLogger.error("Document was not updated",
                                 context: "DocumentsAPI::createDocument")
            return nil
        }

        do {
            let responseData = try await httpService.put(url: "\(DocumentsAPI.documentsUrl)/\(document.id)",
                                                         data: requestData)
            return try JSONDecoder().decode(Document.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When updating document: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: DELETE
    func deleteDocument(document: Document) async -> Document? {
        do {
            let responseData = try await httpService.delete(url: "\(DocumentsAPI.documentsUrl)/\(document.id)")
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
            AnnotatoLogger.error("Could not encode Document into JSON. \(error.localizedDescription)",
                                 context: "DocumentsAPI::encodeDocument")
            return nil
        }
    }
}
