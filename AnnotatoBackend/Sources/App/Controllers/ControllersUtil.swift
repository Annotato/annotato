import Foundation
import Vapor

struct ControllersUtil {
    func getIdFromParams(request: Request) throws -> UUID {
        let param = try getParamValue(request: request, paramKey: "id")

        guard let uuid = UUID(uuidString: param) else {
            request.application.logger.notice("Could not initialise UUID from param")
            throw Abort(.badRequest)
        }

        return uuid
    }

    func getParamValue(request: Request, paramKey: String) throws -> String {
        guard let paramValue = request.parameters.get(paramKey) else {
            request.application.logger.error("Failed to get expected value for key: \(paramKey)")
            throw Abort(.internalServerError)
        }

        return paramValue
    }
}
