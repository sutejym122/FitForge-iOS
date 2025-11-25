//
//  ChatBubble.swift
//  FitForge
//
//  Created by Sutej  Ym  on 11/18/25.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    
    var isUser: Bool {
        message.sender == .user
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            
            // AI bubble alignment
            if !isUser {
                bubble
                Spacer(minLength: 40)
            }
            
            // User bubble alignment
            if isUser {
                Spacer(minLength: 40)
                bubble
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        .transition(.move(edge: isUser ? .trailing : .leading).combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: message.id)
    }
    
    // MARK: - Bubble UI
    private var bubble: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
            
            Text(message.text)
                .padding(12)
                .background(bubbleColor)
                .foregroundColor(isUser ? .white : .black)
                .clipShape(BubbleShape(isUser: isUser))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            
            Text(formattedTimestamp)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(isUser ? .trailing : .leading, 6)
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: isUser ? .trailing : .leading)
    }
    
    private var bubbleColor: Color {
        isUser ? Color.blue : Color(.systemGray5)
    }
    
    // MARK: - Timestamp
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: message.timestamp)
    }
}

// MARK: - Bubble Shape with Tail
struct BubbleShape: Shape {
    var isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let corner: CGFloat = 18
        let tailSize: CGFloat = 8
        
        if isUser {
            // User bubble (right side)
            path.addRoundedRect(in: CGRect(x: rect.minX,
                                           y: rect.minY,
                                           width: rect.width - tailSize,
                                           height: rect.height),
                                cornerSize: CGSize(width: corner, height: corner))
            
            // Tail on right
            path.move(to: CGPoint(x: rect.maxX - tailSize, y: rect.maxY - 20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 14))
            path.addLine(to: CGPoint(x: rect.maxX - tailSize, y: rect.maxY - 6))
        } else {
            // AI bubble (left side)
            path.addRoundedRect(in: CGRect(x: rect.minX + tailSize,
                                           y: rect.minY,
                                           width: rect.width - tailSize,
                                           height: rect.height),
                                cornerSize: CGSize(width: corner, height: corner))
            
            // Tail on left
            path.move(to: CGPoint(x: rect.minX + tailSize, y: rect.maxY - 20))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 14))
            path.addLine(to: CGPoint(x: rect.minX + tailSize, y: rect.maxY - 6))
        }
        
        return path
    }
}

