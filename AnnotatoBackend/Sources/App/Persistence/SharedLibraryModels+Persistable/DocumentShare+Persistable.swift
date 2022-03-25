import Foundation
import AnnotatoSharedLibrary

extension DocumentShare: Persistable {
    static func fromManagedEntity(_ managedEntity: DocumentShareEntity) -> Self {
        Self(
            documentId: managedEntity.$documentEntity.id,
            recipientId: managedEntity.recipientId,
            id: managedEntity.id
        )
    }
}
