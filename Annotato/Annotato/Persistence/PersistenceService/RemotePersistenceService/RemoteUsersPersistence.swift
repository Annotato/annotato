import AnnotatoSharedLibrary
import Foundation

struct RemoteUsersPersistence: UsersPersistence {
    private static let usersUrl = "\(RemotePersistenceService.baseAPIUrl)/users"

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
