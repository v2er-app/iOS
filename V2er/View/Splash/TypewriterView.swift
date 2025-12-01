//
//  TypewriterView.swift
//  V2er
//
//  Created by Claude on 2024/12/1.
//

import SwiftUI

struct TypewriterView: View {
    var text: String
    var typingDelay: Duration = .milliseconds(50)
    var easeIn: Bool = true

    @State private var animatedText: AttributedString = ""
    @State private var typingTask: Task<Void, Error>?
    @State private var hasAppeared = false

    var body: some View {
        Text(animatedText)
            .onChange(of: text) { _ in
                if hasAppeared {
                    animateText()
                }
            }
            .onAppear() {
                animateText()
                hasAppeared = true
            }
    }

    private func animateText() {
        typingTask?.cancel()

        typingTask = Task {
            let defaultAttributes = AttributeContainer()
            animatedText = AttributedString(text,
                                            attributes: defaultAttributes.foregroundColor(.clear)
            )

            let totalChars = text.count
            var charIndex = 0
            var index = animatedText.startIndex

            while index < animatedText.endIndex {
                try Task.checkCancellation()

                // Update the style
                animatedText[animatedText.startIndex...index]
                    .setAttributes(defaultAttributes)

                // Calculate delay with ease-out effect (starts fast, slows down)
                let delay: Duration
                if easeIn && totalChars > 1 {
                    // Ease-out: start fast, end slow - more natural typing feel
                    let progress = Double(charIndex) / Double(totalChars - 1)
                    let easeOutProgress = 1 - pow(1 - progress, 2) // quadratic ease-out
                    let baseDelay = Double(typingDelay.components.attoseconds) / 1_000_000_000_000_000_000
                    let minDelay = baseDelay * 0.6
                    let maxDelay = baseDelay * 1.5
                    let currentDelay = minDelay + (maxDelay - minDelay) * easeOutProgress
                    delay = .milliseconds(Int(currentDelay * 1000))
                } else {
                    delay = typingDelay
                }

                // Wait
                try await Task.sleep(for: delay)

                // Advance the index, character by character
                index = animatedText.index(afterCharacter: index)
                charIndex += 1
            }
        }
    }
}

#Preview {
    TypewriterView(text: "Way to explore")
        .font(.title)
        .padding()
}
