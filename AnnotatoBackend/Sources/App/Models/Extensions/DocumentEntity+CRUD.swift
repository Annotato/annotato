import FluentKit
import AnnotatoSharedLibrary

extension DocumentEntity {
    /// Creates the DocumentEntity instance. Use this function to cascade creates.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - annotation: The new Document instance.
    func customCreate(on tx: Database, usingModel document: Document) async throws {
        try await self.create(on: tx).get()

        for annotation in document.annotations {
            let annotationEntity = AnnotationEntity.fromModel(annotation)
            try await annotationEntity.customCreate(on: tx, usingModel: annotation)
        }
    }

    /// Updates the DocumentEntity instance. Use this function to cascade updates.
    /// - Parameters:
    ///   - tx: The database instance in a transaction.
    ///   - document: The updated Document instance.
    func customUpdate(on tx: Database, usingUpdatedModel document: Document) async throws {
        try await self.loadAssociations(on: tx)
        try await self.pruneOldAssociations(on: tx, usingUpdatedModel: document)
        self.copyPropertiesOf(otherEntity: DocumentEntity.fromModel(document))

        for annotation in document.annotations {
            if let annotationEntity = try await AnnotationEntity.find(annotation.id, on: tx).get() {
                try await annotationEntity.customUpdate(on: tx, usingUpdatedModel: annotation)
            } else {
                let annotationEntity = AnnotationEntity.fromModel(annotation)
                try await annotationEntity.customCreate(on: tx, usingModel: annotation)
            }
        }

        try await self.update(on: tx).get()
    }

    /// Deletes the DocumentEntity instance. Use this function to cascade deletes.
    /// - Parameter tx: The database instance in a transaction.
    func customDelete(on tx: Database) async throws {
        try await self.loadAssociations(on: tx)

        for annotationEntity in annotationEntities {
            try await annotationEntity.customDelete(on: tx)
        }

        try await self.delete(on: tx).get()
    }

    func loadAssociations(on db: Database) async throws {
        try await self.$annotationEntities.load(on: db).get()

        for annotationEntity in self.annotationEntities {
            try await annotationEntity.loadAssociations(on: db)
        }
    }

    func copyPropertiesOf(otherEntity: DocumentEntity) {
        precondition(id == otherEntity.id)

        name = otherEntity.name
        ownerId = otherEntity.ownerId
        baseFileUrl = otherEntity.baseFileUrl
    }

    private func pruneOldAssociations(on tx: Database, usingUpdatedModel document: Document) async throws {
        for annotationEntity in annotationEntities
        where !document.annotations.contains(where: { $0.id == annotationEntity.id }) {
            try await annotationEntity.customDelete(on: tx)
        }
    }
}