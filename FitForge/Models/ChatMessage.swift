//
//  ChatMessage.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//

import Foundation

enum ChatSender: String, Codable {
    case user
    case ai
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let sender: ChatSender
    let text: String
    let timestamp: Date
    
    init(id: UUID = UUID(), sender: ChatSender, text: String, timestamp: Date = Date()) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }
}
