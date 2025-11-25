//
//  ChatStore.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//


import Foundation

class ChatStore {
    private static let key = "fitforge_chat_session"
    
    static func save(_ session: ChatSession) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(session) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func load() -> ChatSession? {
        if let data = UserDefaults.standard.data(forKey: key) {
            let decoder = JSONDecoder()
            if let session = try? decoder.decode(ChatSession.self, from: data) {
                return session
            }
        }
        return nil
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

