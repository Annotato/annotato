//
//  Document.swift
//
//
//  Created by Hong Yao on 12/3/22.
//

import Foundation

public class Document: Codable {
    public var id: UUID?

    public private(set) var name: String

    public let ownerId: UUID

    public let baseFileUrl: String

    public required init(name: String, ownerId: UUID, baseFileUrl: String, id: UUID? = nil) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.baseFileUrl = baseFileUrl
    }
}
