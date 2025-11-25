//
//  ChatThread.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/19/25.
//

import Foundation

struct ChatThread: Identifiable, Codable {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var messages: [ChatMessage]

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        messages: [ChatMessage] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
    }

    mutating func addMessage(_ msg: ChatMessage) {
        messages.append(msg)
        updatedAt = Date()
    }
}
