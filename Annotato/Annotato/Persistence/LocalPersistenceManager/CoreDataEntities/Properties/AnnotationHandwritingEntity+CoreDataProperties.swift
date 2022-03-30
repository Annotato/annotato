import Foundation
import CoreData

extension AnnotationHandwritingEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnnotationHandwritingEntity> {
        NSFetchRequest<AnnotationHandwritingEntity>(entityName: "AnnotationHandwritingEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var order: Int64
    @NSManaged public var height: Double
    @NSManaged public var handwriting: Data

    // Relations
    @NSManaged public var annotationEntity: AnnotationEntity

    // Timestamps
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}

extension AnnotationHandwritingEntity: Identifiable {

}
