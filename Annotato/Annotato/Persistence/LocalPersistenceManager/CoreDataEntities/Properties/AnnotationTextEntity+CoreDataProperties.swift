import Foundation
import CoreData
import AnnotatoSharedLibrary

extension AnnotationTextEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnnotationTextEntity> {
        NSFetchRequest<AnnotationTextEntity>(entityName: "AnnotationTextEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var type: AnnotationText.TextType
    @NSManaged public var order: Int64
    @NSManaged public var height: Double
    @NSManaged public var content: String

    // Relations
    @NSManaged public var annotationEntity: AnnotationEntity

    // Timestamps
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}

extension AnnotationTextEntity: Identifiable {
    var annotationId: UUID {
        annotationEntity.id
    }
}
