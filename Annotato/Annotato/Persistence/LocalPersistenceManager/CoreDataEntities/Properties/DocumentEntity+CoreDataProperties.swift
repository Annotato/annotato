import Foundation
import CoreData

extension DocumentEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentEntity> {
        NSFetchRequest<DocumentEntity>(entityName: "DocumentEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var ownerId: String
    @NSManaged public var baseFileUrl: String

    @NSManaged public var annotationEntities: Set<AnnotationEntity>

    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}

// MARK: Generated accessors for annotationEntities
extension DocumentEntity {
    @objc(addAnnotationEntitiesObject:)
    @NSManaged public func addToAnnotationEntities(_ value: AnnotationEntity)

    @objc(removeAnnotationEntitiesObject:)
    @NSManaged public func removeFromAnnotationEntities(_ value: AnnotationEntity)

    @objc(addAnnotationEntities:)
    @NSManaged public func addToAnnotationEntities(_ values: Set<AnnotationEntity>)

    @objc(removeAnnotationEntities:)
    @NSManaged public func removeFromAnnotationEntities(_ values: Set<AnnotationEntity>)
}

// MARK: Generated accessors for documentShareEntities
extension DocumentEntity {
    @objc(addDocumentShareEntitiesObject:)
    @NSManaged public func addToDocumentShareEntities(_ value: DocumentShareEntity)

    @objc(removeDocumentShareEntitiesObject:)
    @NSManaged public func removeFromDocumentShareEntities(_ value: DocumentShareEntity)

    @objc(addDocumentShareEntities:)
    @NSManaged public func addToDocumentShareEntities(_ values: Set<DocumentShareEntity>)

    @objc(removeDocumentShareEntities:)
    @NSManaged public func removeFromDocumentShareEntities(_ values: Set<DocumentShareEntity>)
}

extension DocumentEntity: Identifiable {

}
