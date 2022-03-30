import Foundation
import CoreData


extension AnnotationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnnotationEntity> {
        return NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var originX: Double
    @NSManaged public var originY: Double
    @NSManaged public var ownerId: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var width: Double
    @NSManaged public var annotationHandwritingEntities: NSSet?
    @NSManaged public var annotationTextEntities: NSSet?
    @NSManaged public var documentEntity: DocumentEntity?

}

// MARK: Generated accessors for annotationHandwritingEntities
extension AnnotationEntity {

    @objc(addAnnotationHandwritingEntitiesObject:)
    @NSManaged public func addToAnnotationHandwritingEntities(_ value: AnnotationHandwritingEntity)

    @objc(removeAnnotationHandwritingEntitiesObject:)
    @NSManaged public func removeFromAnnotationHandwritingEntities(_ value: AnnotationHandwritingEntity)

    @objc(addAnnotationHandwritingEntities:)
    @NSManaged public func addToAnnotationHandwritingEntities(_ values: NSSet)

    @objc(removeAnnotationHandwritingEntities:)
    @NSManaged public func removeFromAnnotationHandwritingEntities(_ values: NSSet)

}

// MARK: Generated accessors for annotationTextEntities
extension AnnotationEntity {

    @objc(addAnnotationTextEntitiesObject:)
    @NSManaged public func addToAnnotationTextEntities(_ value: AnnotationTextEntity)

    @objc(removeAnnotationTextEntitiesObject:)
    @NSManaged public func removeFromAnnotationTextEntities(_ value: AnnotationTextEntity)

    @objc(addAnnotationTextEntities:)
    @NSManaged public func addToAnnotationTextEntities(_ values: NSSet)

    @objc(removeAnnotationTextEntities:)
    @NSManaged public func removeFromAnnotationTextEntities(_ values: NSSet)

}
