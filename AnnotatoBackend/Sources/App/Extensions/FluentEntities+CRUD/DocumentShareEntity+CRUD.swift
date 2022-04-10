import Foundation
import FluentKit

extension DocumentShareEntity {
    /// Creates the DocumentShareEntity instance.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    func customCreate(on tx: Database) async throws {
        try await self.create(on: tx).get()
    }

    /// Deletes the DocumentShareEntity instance. Use this function to cascade deletes.
    /// - Parameter tx: The database instance in a transaction.
    func customDelete(on tx: Database) async throws {
        try await self.restore(on: tx)
        try await self.delete(on: tx).get()
    }
}
