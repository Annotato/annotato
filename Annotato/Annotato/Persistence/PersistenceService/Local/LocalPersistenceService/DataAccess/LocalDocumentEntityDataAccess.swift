import Foundation
import AnnotatoSharedLibrary

struct LocalDocumentEntityDataAccess {
    let context = CoreDataManager.sharedContext

    func listOwn(userId: String) -> [DocumentEntity]? {
        context.performAndWait {
            context.rollback()

            let request = DocumentEntity.fetchRequest()

            do {
                let documentEntities = try context.fetch(request).filter { $0.ownerId == userId }

                return DocumentEntity.removeDeletedDocumentEntities(documentEntities)
            } catch {
                AnnotatoLogger.error("When fetching own document entities. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::listOwn")
                return nil
            }
        }
    }

    func listShared(userId: String) -> [DocumentEntity]? {
        context.performAndWait {
            context.rollback()

            let request = DocumentEntity.fetchRequest()

            do {
                let documentEntities = try context.fetch(request).filter { $0.ownerId != userId }

                return DocumentEntity.removeDeletedDocumentEntities(documentEntities)
            } catch {
                AnnotatoLogger.error("When fetching shared document entities. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::listShared")
                return nil
            }
        }
    }

    func listCreatedAfterDate(date: Date) -> [DocumentEntity]? {
        context.performAndWait {
            context.rollback()

            let request = DocumentEntity.fetchRequest()

            do {
                let documentEntities = try context.fetch(request).filter { $0.wasCreated(after: date) }

                return documentEntities
            } catch {
                AnnotatoLogger.error("When fetching created document entities after date. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::listCreatedAfterDate")
                return nil
            }
        }
    }

    func listUpdatedAfterDate(date: Date) -> [DocumentEntity]? {
        context.performAndWait {
            context.rollback()

            let request = DocumentEntity.fetchRequest()

            do {
                let documentEntities = try context.fetch(request).filter { $0.wasUpdated(after: date) }

                return documentEntities
            } catch {
                AnnotatoLogger.error("When fetching updated document entities after date. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::listUpdatedAfterDate")
                return nil
            }
        }
    }

    func create(document: Document) -> DocumentEntity? {
        context.performAndWait {
            context.rollback()

            let documentEntity = DocumentEntity.fromModel(document)

            do {
                try context.save()
            } catch {
                AnnotatoLogger.error("When creating document: \(String(describing: error))",
                                     context: "LocalDocumentsPersistence::create")
                return nil
            }

            return documentEntity
        }
    }

    func read(documentId: UUID, withDeleted: Bool) -> DocumentEntity? {
        context.performAndWait {
            context.rollback()

            let request = DocumentEntity.fetchRequest()

            do {
                var documentEntities = try context.fetch(request).filter { $0.id == documentId }
                if !withDeleted {
                    documentEntities = DocumentEntity.removeDeletedDocumentEntities(documentEntities)
                }

                return documentEntities.first
            } catch {
                AnnotatoLogger.error("When fetching document entity. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::read")
                return nil
            }
        }
    }

    func readInCurrentContext(documentId: UUID, withDeleted: Bool) -> DocumentEntity? {
        let request = DocumentEntity.fetchRequest()

        do {
            var documentEntities = try context.fetch(request).filter { $0.id == documentId }
            if !withDeleted {
                documentEntities = DocumentEntity.removeDeletedDocumentEntities(documentEntities)
            }

            return documentEntities.first
        } catch {
            AnnotatoLogger.error("When fetching document entity. \(String(describing: error))",
                                 context: "LocalDocumentEntityDataAccess::read")
            return nil
        }
    }

    func update(documentId: UUID, document: Document) -> DocumentEntity? {
        context.performAndWait {
            context.rollback()

            guard let documentEntity = readInCurrentContext(documentId: documentId,
                                                            withDeleted: true) else {
                AnnotatoLogger.error("When finding existing document entity.",
                                     context: "LocalDocumentEntityDataAccess::update")
                return nil
            }

            documentEntity.customUpdate(usingUpdatedModel: document)

            do {
                try context.save()
            } catch {
                AnnotatoLogger.error("When updating document entity. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::update")
                return nil
            }

            return documentEntity
        }
    }

    func delete(documentId: UUID, document: Document) -> DocumentEntity? {
        context.performAndWait {
            context.rollback()

            guard let documentEntity = readInCurrentContext(documentId: documentId, withDeleted: true) else {
                AnnotatoLogger.error("When finding existing document entity.",
                                     context: "LocalDocumentEntityDataAccess::delete")
                return nil
            }

            context.delete(documentEntity)

            do {
                try context.save()
            } catch {
                AnnotatoLogger.error("When deleting document entity. \(String(describing: error))",
                                     context: "LocalDocumentEntityDataAccess::delete")
                return nil
            }

            return documentEntity
        }
    }
}
