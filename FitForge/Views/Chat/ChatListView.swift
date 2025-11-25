//
//  ChatListView.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/19/25.
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var store = MultiChatStore()

    let profile: UserProfile
    let macros: MetabolicResult

    @State private var activeThread: ChatThread? = nil

    var body: some View {
        NavigationStack {
            VStack {
                if store.threads.isEmpty {
                    emptyState
                }

                List {
                    ForEach(store.threads) { thread in
                        Button {
                            activeThread = thread
                        } label: {
                            chatRow(thread)
                        }
                    }
                    .onDelete(perform: deleteThreads)
                }
            }
            .navigationTitle("Coach")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        createThread()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(item: $activeThread) { thread in
                ChatView(
                    thread: thread,
                    store: store,
                    profile: profile,
                    macros: macros
                )
            }
        }
    }

    // MARK: - Row UI
    private func chatRow(_ thread: ChatThread) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(thread.title)
                    .font(.headline)

                if let last = thread.messages.last {
                    Text(last.text)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                } else {
                    Text("No messages yet")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }

            Spacer()

            Text(formatDate(thread.updatedAt))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("No conversations yet")
                .font(.title3)
                .foregroundColor(.gray)

            Text("Start your first chat with your coach.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 60)
    }

    // MARK: - Actions
    private func createThread() {
        let newThread = store.createThread(title: "New Chat")
        activeThread = newThread
    }

    private func deleteThreads(at offsets: IndexSet) {
        offsets.forEach { index in
            let thread = store.threads[index]
            store.deleteThread(thread)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}
