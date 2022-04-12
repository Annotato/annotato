import AnnotatoSharedLibrary
import Foundation

struct RemoteUsersPersistence {
    private static let usersUrl = "\(RemotePersistenceService.baseAPIUrl)/users"
    private static let usersSharingDocumentUrl = "\(usersUrl)/sharing"

    private var httpService: AnnotatoHTTPService

    init() {
        httpService = URLSessionHTTPService()
    }

    // MARK: CREATE
    func createUser(user: AnnotatoUser) async -> AnnotatoUser? {
        guard let requestData = encodeUser(user) else {
            AnnotatoLogger.error("User was not created",
                                 context: "RemoteUsersPersistence::createUser")
            return nil
        }

        do {
            let responseData = try await httpService.post(url: RemoteUsersPersistence.usersUrl, data: requestData)
            return try JSONCustomDecoder().decode(AnnotatoUser.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When creating user: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: READ
    func getUser(userId: String) async -> AnnotatoUser? {
        do {
            let responseData = try await httpService.get(url: "\(RemoteUsersPersistence.usersUrl)/\(userId)")
            return try JSONCustomDecoder().decode(AnnotatoUser.self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching user: \(String(describing: error))")
            return nil
        }
    }

    // MARK: LIST SHARING
    func getUsersSharingDocument(documentId: UUID) async -> [AnnotatoUser]? {
        do {
            let responseData = try await httpService.get(
                url: "\(RemoteUsersPersistence.usersSharingDocumentUrl)",
                params: ["documentId": documentId.uuidString]
            )
            return try JSONCustomDecoder().decode([AnnotatoUser].self, from: responseData)
        } catch {
            AnnotatoLogger.error("When fetching users sharing document \(documentId): \(String(describing: error))")
            return nil
        }
    }

    private func encodeUser(_ user: AnnotatoUser) -> Data? {
        do {
            let data = try JSONCustomEncoder().encode(user)
            return data
        } catch {
            AnnotatoLogger.error("Could not encode User into JSON. \(error.localizedDescription)",
                                 context: "RemoteUsersPersistence::encodeUser")
            return nil
        }
    }
}
