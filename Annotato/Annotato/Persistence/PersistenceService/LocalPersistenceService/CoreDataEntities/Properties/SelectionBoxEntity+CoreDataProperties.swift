import Foundation
import CoreData

extension SelectionBoxEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelectionBoxEntity> {
        NSFetchRequest<SelectionBoxEntity>(entityName: "SelectionBoxEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var startPointX: Double
    @NSManaged public var startPointY: Double
    @NSManaged public var endPointX: Double
    @NSManaged public var endPointY: Double

    @NSManaged public var annotationEntity: AnnotationEntity

    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}

extension SelectionBoxEntity: Identifiable {
    var annotationId: UUID {
        annotationEntity.id
    }
}
