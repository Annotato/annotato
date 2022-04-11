import Foundation
import AnnotatoSharedLibrary

extension DocumentShare: Persistable {
    static func fromManagedEntity(_ managedEntity: DocumentShareEntity) -> Self {
        Self(
            documentId: managedEntity.$documentEntity.id,
            recipientId: managedEntity.$recipientEntity.id,
            id: managedEntity.id,
            createdAt: managedEntity.createdAt,
            updatedAt: managedEntity.updatedAt,
            deletedAt: managedEntity.deletedAt
        )
    }
}
