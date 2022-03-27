import FluentKit
import AnnotatoSharedLibrary

extension AnnotationEntity {
    /// Creates the AnnotationEntity instance. Use this function to cascade creates.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - annotation: The new Annotation instance.
    func customCreate(on tx: Database, usingModel annotation: Annotation) async throws {
        try await self.create(on: tx).get()

        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })
        for annotationText in annotationTexts {
            let annotationTextEntity = AnnotationTextEntity.fromModel(annotationText)
            try await annotationTextEntity.customCreate(on: tx)
        }

        let annotationHandwritings = annotation.parts.compactMap({ $0 as? AnnotationHandwriting })
        for annotationHandwriting in annotationHandwritings {
            let annotationHandwritingEntity = AnnotationHandwritingEntity.fromModel(annotationHandwriting)
            try await annotationHandwritingEntity.customCreate(on: tx)
        }
    }

    /// Updates the AnnotationEntity instance. Use this function to cascade updates.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - annotation: The updated Annotation instance.
    func customUpdate(on tx: Database, usingUpdatedModel annotation: Annotation) async throws {
        try await self.loadAssociations(on: tx)
        try await self.pruneOldAssociations(on: tx, usingUpdatedModel: annotation)
        self.copyPropertiesOf(otherEntity: AnnotationEntity.fromModel(annotation))

        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })
        for annotationText in annotationTexts {
            if let annotationTextEntity = try await AnnotationTextEntity.find(annotationText.id, on: tx).get() {
                try await annotationTextEntity.customUpdate(on: tx, usingUpdatedModel: annotationText)
            } else {
                let annotationTextEntity = AnnotationTextEntity.fromModel(annotationText)
                try await annotationTextEntity.customCreate(on: tx)
            }
        }

        let annotationHandwritings = annotation.parts.compactMap({ $0 as? AnnotationHandwriting })
        for annotationHandwriting in annotationHandwritings {
            if let annotationHandwritingEntity = try await AnnotationHandwritingEntity.find(annotationHandwriting.id,
                                                                                            on: tx).get() {
                try await annotationHandwritingEntity.customUpdate(on: tx, usingUpdatedModel: annotationHandwriting)
            } else {
                let annotationHandwritingEntity = AnnotationHandwritingEntity.fromModel(annotationHandwriting)
                try await annotationHandwritingEntity.customCreate(on: tx)
            }
        }

        try await self.update(on: tx).get()
    }

    /// Deletes the AnnotationEntity instance. Use this function to cascade deletes.
    /// - Parameter tx: The database instance in a transaction.
    func customDelete(on tx: Database) async throws {
        try await self.loadAssociations(on: tx)

        for textEntity in annotationTextEntities {
            try await textEntity.customDelete(on: tx)
        }

        for handwritingEntity in annotationHandwritingEntities {
            try await handwritingEntity.customDelete(on: tx)
        }

        try await self.delete(on: tx).get()
    }

    func loadAssociations(on db: Database) async throws {
        try await self.$annotationTextEntities.load(on: db).get()
        try await self.$annotationHandwritingEntities.load(on: db).get()
    }

    func copyPropertiesOf(otherEntity: AnnotationEntity) {
        precondition(id == otherEntity.id)

        originX = otherEntity.originX
        originY = otherEntity.originY
        width = otherEntity.width
        ownerId = otherEntity.ownerId
        $documentEntity.id = otherEntity.$documentEntity.id
    }

    private func pruneOldAssociations(on tx: Database, usingUpdatedModel annotation: Annotation) async throws {
        let annotationTexts = annotation.parts.compactMap({ $0 as? AnnotationText })
        for annotationTextEntity in annotationTextEntities
        where !annotationTexts.contains(where: { $0.id == annotationTextEntity.id }) {
            try await annotationTextEntity.customDelete(on: tx)
        }

        let annotationHandwritings = annotation.parts.compactMap { $0 as? AnnotationHandwriting }
        for annotationHandwritingEntity in annotationHandwritingEntities
        where !annotationHandwritings.contains(where: { $0.id == annotationHandwritingEntity.id }) {
            try await annotationHandwritingEntity.customDelete(on: tx)
        }
    }
}
