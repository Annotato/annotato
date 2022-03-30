import Foundation
import CoreData

extension AnnotationTextEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnnotationTextEntity> {
        NSFetchRequest<AnnotationTextEntity>(entityName: "AnnotationTextEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: Int64
    @NSManaged public var order: Int64
    @NSManaged public var height: Double
    @NSManaged public var content: String?
    @NSManaged public var annotationEntity: AnnotationEntity?

    // Timestamps
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var updatedAt: Date?
}
