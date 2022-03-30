import AnnotatoSharedLibrary

extension DocumentEntity: PersistedEntity {
    static func fromModel(_ model: Document) -> DocumentEntity {
        let entity = LocalPersistenceManager.shared.makeCoreDataEntity(class: Document.self)

        entity.id = model.id
        entity.name = model.name
        entity.ownerId = model.ownerId
        entity.baseFileUrl = model.baseFileUrl
        
        // TODO: Fetch
        entity.annotationEntities = []
        entity.documentShareEntities = []

        return entity
    }
}
@NSManaged public var name: String
@NSManaged public var ownerId: String
@NSManaged public var baseFileUrl: String
