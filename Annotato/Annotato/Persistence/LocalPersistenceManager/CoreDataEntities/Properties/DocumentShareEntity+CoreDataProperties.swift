import Foundation
import CoreData

extension DocumentShareEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentShareEntity> {
        NSFetchRequest<DocumentShareEntity>(entityName: "DocumentShareEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var recipientId: String

    // Relations
    @NSManaged public var documentEntity: DocumentEntity

    // Timestamps
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}

extension DocumentShareEntity: Identifiable {
    var documentId: UUID {
        documentEntity.id
    }
}
