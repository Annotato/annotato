import Foundation
import CoreData


extension AnnotationTextEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnnotationTextEntity> {
        return NSFetchRequest<AnnotationTextEntity>(entityName: "AnnotationTextEntity")
    }

    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var height: Double
    @NSManaged public var id: UUID?
    @NSManaged public var order: Int64
    @NSManaged public var type: Int64
    @NSManaged public var updatedAt: Date?
    @NSManaged public var annotationEntity: AnnotationEntity?

}
