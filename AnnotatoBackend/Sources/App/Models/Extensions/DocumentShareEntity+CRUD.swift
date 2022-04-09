import Foundation
import FluentKit

extension DocumentShareEntity {
    /// Creates the DocumentShareEntity instance.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    func customCreate(on tx: Database) async throws {
        try await self.create(on: tx).get()
    }
}
