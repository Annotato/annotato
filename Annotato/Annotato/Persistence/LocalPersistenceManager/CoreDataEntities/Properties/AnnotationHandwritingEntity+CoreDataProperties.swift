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

    @NSManaged public var annotationEntity: AnnotationEntity

    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}

extension AnnotationHandwritingEntity: Identifiable {
    var annotationId: UUID {
        annotationEntity.id
    }

    static func removeDeletedAnnotationHandwritingEntities(
        _ entities: [AnnotationHandwritingEntity]
    ) -> [AnnotationHandwritingEntity] {
        entities.filter({ $0.deletedAt != nil })
    }
}
