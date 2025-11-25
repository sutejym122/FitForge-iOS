//
//  ChatView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel

    let thread: ChatThread
    let store: MultiChatStore
    let profile: UserProfile
    let macros: MetabolicResult

    // MARK: - Initializer
    init(
        thread: ChatThread,
        store: MultiChatStore,
        profile: UserProfile,
        macros: MetabolicResult
    ) {
        self.thread = thread
        self.store = store
        self.profile = profile
        self.macros = macros

        _viewModel = StateObject(
            wrappedValue: ChatViewModel(
                thread: thread,
                profile: profile,
                macros: macros,
                store: store
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {

            // Quick Prompts
            quickPrompts

            // Messages
            messagesList

            // Input bar
            inputBar
                .background(.ultraThinMaterial)
        }
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Reset") {
                withAnimation {
                    viewModel.resetThread()
                }
            }
        }
    }

    // MARK: - Quick Prompts
    private var quickPrompts: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(QuickPrompts.prompts(for: profile.goal), id: \.self) { prompt in
                    Button {
                        viewModel.sendQuickPrompt(prompt)
                    } label: {
                        Text(prompt)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(14)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    // MARK: - Messages List
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.thread.messages) { msg in
                        ChatBubble(message: msg)
                            .id(msg.id)
                    }

                    if viewModel.isTypingResponse {
                        TypingIndicator()   // <-- using external file
                            .padding(.leading)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 6)
                .onChange(of: viewModel.thread.messages.count) { _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(viewModel.thread.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask your fitness coach...", text: $viewModel.inputText)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(viewModel.inputText.isEmpty ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(viewModel.inputText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}


