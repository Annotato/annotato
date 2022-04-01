import Foundation
import CoreData

extension AnnotationEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnnotationEntity> {
        NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var width: Double
    @NSManaged public var ownerId: String
    @NSManaged public var originX: Double
    @NSManaged public var originY: Double

    // Relations
    @NSManaged public var documentEntity: DocumentEntity
    @NSManaged public var selectionBoxEntity: SelectionBoxEntity
    @NSManaged public var annotationTextEntities: Set<AnnotationTextEntity>
    @NSManaged public var annotationHandwritingEntities: Set<AnnotationHandwritingEntity>

    // Timestamps
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}

// MARK: Generated accessors for annotationHandwritingEntities
extension AnnotationEntity {
    @objc(addAnnotationHandwritingEntitiesObject:)
    @NSManaged public func addToAnnotationHandwritingEntities(_ value: AnnotationHandwritingEntity)

    @objc(removeAnnotationHandwritingEntitiesObject:)
    @NSManaged public func removeFromAnnotationHandwritingEntities(_ value: AnnotationHandwritingEntity)

    @objc(addAnnotationHandwritingEntities:)
    @NSManaged public func addToAnnotationHandwritingEntities(_ values: Set<AnnotationHandwritingEntity>)

    @objc(removeAnnotationHandwritingEntities:)
    @NSManaged public func removeFromAnnotationHandwritingEntities(_ values: Set<AnnotationHandwritingEntity>)
}

// MARK: Generated accessors for annotationTextEntities
extension AnnotationEntity {
    @objc(addAnnotationTextEntitiesObject:)
    @NSManaged public func addToAnnotationTextEntities(_ value: AnnotationTextEntity)

    @objc(removeAnnotationTextEntitiesObject:)
    @NSManaged public func removeFromAnnotationTextEntities(_ value: AnnotationTextEntity)

    @objc(addAnnotationTextEntities:)
    @NSManaged public func addToAnnotationTextEntities(_ values: Set<AnnotationTextEntity>)

    @objc(removeAnnotationTextEntities:)
    @NSManaged public func removeFromAnnotationTextEntities(_ values: Set<AnnotationTextEntity>)
}

extension AnnotationEntity: Identifiable {
    var documentId: UUID {
        documentEntity.id
    }
}
