import Foundation
import Vapor

struct ControllersUtil {
    static func getIdFromParams(request: Request) throws -> UUID {
        let param = try getParamValue(request: request, paramKey: "id")

        guard let uuid = UUID(uuidString: param) else {
            request.application.logger.notice("Could not initialise UUID from param")
            throw Abort(.badRequest)
        }

        return uuid
    }

    static func getIdFromParamsAsString(request: Request) throws -> String {
        return try getParamValue(request: request, paramKey: "id")
    }

    private static func getParamValue(request: Request, paramKey: String) throws -> String {
        guard let paramValue = request.parameters.get(paramKey) else {
            request.application.logger.error("Failed to get expected value for key: \(paramKey)")
            throw Abort(.internalServerError)
        }

        return paramValue
    }
}
