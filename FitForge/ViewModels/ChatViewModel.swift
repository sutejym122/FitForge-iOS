//
//  ChatViewModel.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//

import Foundation
import SwiftUI

final class ChatViewModel: ObservableObject {

    @Published var thread: ChatThread
    @Published var inputText: String = ""
    @Published var isTypingResponse: Bool = false

    let profile: UserProfile
    let macros: MetabolicResult
    let store: MultiChatStore

    // MARK: - Initializer
    init(
        thread: ChatThread,
        profile: UserProfile,
        macros: MetabolicResult,
        store: MultiChatStore
    ) {
        self.thread = thread
        self.profile = profile
        self.macros = macros
        self.store = store
    }

    // MARK: - Send Message
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 1️⃣ Append user message locally
        let userMsg = ChatMessage(sender: .user, text: trimmed)
        thread.addMessage(userMsg)
        saveThread()

        inputText = ""
        isTypingResponse = true

        // 2️⃣ Call backend with full history
        AIChatService.sendMessageAdvanced(
            message: trimmed,
            profile: profile,
            macros: macros,
            history: thread.messages
        ) { [weak self] reply in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isTypingResponse = false

                let aiMsg = ChatMessage(
                    sender: .ai,
                    text: reply ?? "Sorry, I didn’t get that."
                )
                self.thread.addMessage(aiMsg)
                self.saveThread()
            }
        }
    }

    // MARK: - Quick Prompt
    func sendQuickPrompt(_ text: String) {
        inputText = text
        sendMessage()
    }

    // MARK: - Reset Thread
    func resetThread() {
        thread.messages.removeAll()
        thread.updatedAt = Date()
        saveThread()
    }

    // MARK: - Persist
    private func saveThread() {
        store.updateThread(thread)
    }
}

