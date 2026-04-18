//
//  MessageInputView.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var text: String
    let onSend: () -> Void
    let isLoading: Bool
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .focused($isFocused)
                .lineLimit(1...5)
                .submitLabel(.send)
                .onSubmit {
                    sendMessage()
                }
                .disabled(isLoading)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? .blue : .gray)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
    }
    
    private func sendMessage() {
        guard canSend else { return }
        onSend()
        // Text clearing is now handled by parent view
        isFocused = true
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        MessageInputView(
            text: .constant(""),
            onSend: {},
            isLoading: false
        )
    }
}
