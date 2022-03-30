import Foundation
import CoreData


extension AnnotationHandwritingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnnotationHandwritingEntity> {
        return NSFetchRequest<AnnotationHandwritingEntity>(entityName: "AnnotationHandwritingEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var handwriting: Data?
    @NSManaged public var height: Double
    @NSManaged public var id: UUID?
    @NSManaged public var order: Int64
    @NSManaged public var updatedAt: Date?
    @NSManaged public var annotationEntity: AnnotationEntity?

}
