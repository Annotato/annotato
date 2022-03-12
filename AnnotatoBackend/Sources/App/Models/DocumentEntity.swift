//
//  DocumentEntity.swift
//  
//
//  Created by Hong Yao on 12/3/22.
//

import FluentKit

final class DocumentEntity: Model {
    static let schema = "documents"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "owner_id")
    var ownerId: UUID

    @Field(key: "base_file_url")
    var baseFileUrl: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }
}
