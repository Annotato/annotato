import Foundation
import CoreData
import AnnotatoSharedLibrary

extension DocumentShareEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentShareEntity> {
        NSFetchRequest<DocumentShareEntity>(entityName: "DocumentShareEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var recipientId: String

    @NSManaged public var createdAt: Date
    @NSManaged public var deletedAt: Date
    @NSManaged public var updatedAt: Date

    @NSManaged public var documentEntity: DocumentEntity

}

extension DocumentShareEntity {
    var documentId: UUID {
        UUID()
    }
}
