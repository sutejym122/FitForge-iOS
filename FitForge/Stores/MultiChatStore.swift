//
//  MultiChatStore.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/19/25.
//

import Foundation

final class MultiChatStore: ObservableObject {

    @Published var threads: [ChatThread] = []

    private let storageKey = "multi_chat_threads_v1"

    init() {
        load()
        if threads.isEmpty {
            let first = ChatThread(title: "Coach")
            threads = [first]
            save()
        }
    }

    // MARK: - CRUD

    @discardableResult
    func createThread(title: String = "New Chat") -> ChatThread {
        let thread = ChatThread(title: title)
        threads.insert(thread, at: 0)
        save()
        return thread
    }

    func deleteThread(_ thread: ChatThread) {
        threads.removeAll { $0.id == thread.id }
        if threads.isEmpty {
            let first = ChatThread(title: "Coach")
            threads = [first]
        }
        save()
    }

    func updateThread(_ thread: ChatThread) {
        if let idx = threads.firstIndex(where: { $0.id == thread.id }) {
            threads[idx] = thread
            save()
        }
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(threads)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ Failed saving threads:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            threads = try JSONDecoder().decode([ChatThread].self, from: data)
        } catch {
            print("❌ Failed loading threads:", error)
        }
    }
}


