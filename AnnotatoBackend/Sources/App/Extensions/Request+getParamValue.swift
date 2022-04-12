import Vapor
import Foundation

extension Request {
    func getParamValue(paramKey: String) throws -> String {
        guard let paramValue = self.parameters.get(paramKey) else {
            self.application.logger.error("Failed to get expected value for key: \(paramKey)")
            throw Abort(.internalServerError)
        }

        return paramValue
    }

    func getParamValueAsUUID(paramKey: String) throws -> UUID {
        let paramValue = try self.getParamValue(paramKey: paramKey)

        guard let uuid = UUID(uuidString: paramValue) else {
            self.application.logger.notice("Could not initialise UUID from param")
            throw Abort(.badRequest)
        }

        return uuid
    }

    func getIdValue() throws -> String {
        try self.getParamValue(paramKey: "id")
    }

    func getIdValueAsUUID() throws -> UUID {
        try self.getParamValueAsUUID(paramKey: "id")
    }
}
