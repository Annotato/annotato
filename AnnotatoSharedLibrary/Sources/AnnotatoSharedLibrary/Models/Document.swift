//
//  Document.swift
//
//
//  Created by Hong Yao on 12/3/22.
//

import Foundation

class Document {
    let id: UUID

    private(set) var name: String

    let ownerId: UUID

    let baseFileUrl: String

    init(name: String, ownerId: UUID, baseFileUrl: String, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
    }
}
