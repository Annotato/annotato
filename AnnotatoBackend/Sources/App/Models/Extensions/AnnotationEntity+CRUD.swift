import FluentKit
import AnnotatoSharedLibrary

extension AnnotationEntity {
    func copyPropertiesOf(otherEntity: AnnotationEntity) {
        precondition(id == otherEntity.id)

        originX = otherEntity.originX
        originY = otherEntity.originY
        width = otherEntity.width
        ownerId = otherEntity.ownerId
        $documentEntity.id = otherEntity.$documentEntity.id
    }

    func loadAssociations(on db: Database) async throws {
        try await self.$annotationTextEntities.load(on: db).get()
    }

    func customUpdate(on tx: Database, usingUpdatedModel annotation: Annotation) async throws {
        try await self.loadAssociations(on: tx)
        try await self.pruneOldAssociations(on: tx, using: annotation)
        self.copyPropertiesOf(otherEntity: AnnotationEntity.fromModel(annotation))
        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })

        for annotationText in annotationTexts {
            if let annotationTextEntity = try await AnnotationTextEntity.find(annotationText.id, on: tx).get() {
                try await annotationTextEntity.customUpdate(on: tx, usingUpdatedModel: annotationText)
            } else {
                try await AnnotationTextEntity.fromModel(annotationText).create(on: tx).get()
            }
        }

        return try await self.update(on: tx).get()
    }

    func customDelete(on tx: Database) async throws {
        try await self.loadAssociations(on: tx)

        for textEntity in annotationTextEntities {
            try await textEntity.customDelete(on: tx)
        }

        try await self.delete(on: tx).get()
    }

    private func pruneOldAssociations(on tx: Database, using annotation: Annotation) async throws {
        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })

        for annotationTextEntity in annotationTextEntities where !annotationTexts.contains(where: { $0.id == annotationTextEntity.id }) {
            try await annotationTextEntity.customDelete(on: tx)
        }
    }
}
