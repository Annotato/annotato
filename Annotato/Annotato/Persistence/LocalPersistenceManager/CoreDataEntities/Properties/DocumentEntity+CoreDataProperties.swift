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

extension DocumentEntity: Identifiable {
    static func removeDeletedDocumentEntities(_ entities: [DocumentEntity]) -> [DocumentEntity] {
        let undeletedDocumentEntities = entities.filter({ $0.deletedAt == nil })

        for undeletedDocumentEntity in undeletedDocumentEntities {
            let annotationEntites = Array(undeletedDocumentEntity.annotationEntities)

            let undeletedAnnotationEntities = AnnotationEntity
                .removeDeletedAnnotationEntities(annotationEntites)

            undeletedDocumentEntity.annotationEntities = Set<AnnotationEntity>(undeletedAnnotationEntities)
        }

        return undeletedDocumentEntities
    }
}
