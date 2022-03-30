import Foundation
import CoreData


extension DocumentShareEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentShareEntity> {
        return NSFetchRequest<DocumentShareEntity>(entityName: "DocumentShareEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var recipientId: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var documentEntity: DocumentEntity?

}
