//
//  RichView+Preview.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI

@available(iOS 18.0, *)
struct RichView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Basic text with formatting
            RichView(htmlContent: Self.basicExample)
                .configuration(.default)
                .padding()
                .previewDisplayName("Basic Text")

            // Links and inline code
            RichView(htmlContent: Self.linksAndCodeExample)
                .configuration(.default)
                .padding()
                .previewDisplayName("Links & Code")

            // Mixed formatting
            RichView(htmlContent: Self.mixedFormattingExample)
                .configuration(.default)
                .padding()
                .previewDisplayName("Mixed Formatting")

            // Dark mode
            RichView(htmlContent: Self.basicExample)
                .configuration(.default)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")

            // Compact style (for replies)
            RichView(htmlContent: Self.replyExample)
                .configuration(.compact)
                .padding()
                .previewDisplayName("Compact Style")

            // Custom stylesheet
            RichView(htmlContent: Self.basicExample)
                .stylesheet(Self.customStylesheet)
                .padding()
                .previewDisplayName("Custom Style")

            // Error state
            RichView(htmlContent: Self.errorExample)
                .configuration(.debug)
                .padding()
                .previewDisplayName("Error State")
        }
    }

    // MARK: - Example Content

    static let basicExample = """
        <p>This is a <strong>bold text</strong> and this is <em>italic text</em>.</p>
        <p>Here is a new paragraph with some regular text.</p>
        <br>
        <p>After a line break, we have more content.</p>
        """

    static let linksAndCodeExample = """
        <p>Check out this <a href="https://www.v2ex.com">V2EX link</a> and some <code>inline code</code>.</p>
        <pre><code>func helloWorld() {
            print("Hello, World!")
        }</code></pre>
        <p>Links can be <a href="/t/12345">relative</a> or <a href="//cdn.v2ex.com/image.png">protocol-relative</a>.</p>
        """

    static let mixedFormattingExample = """
        <h1>Main Heading</h1>
        <p>This is a paragraph with <strong>bold</strong>, <em>italic</em>, and <code>code</code>.</p>
        <h2>Subheading</h2>
        <blockquote>
            This is a blockquote with some quoted text.
        </blockquote>
        <ul>
            <li>First item</li>
            <li>Second item</li>
            <li>Third item</li>
        </ul>
        <h3>Another Section</h3>
        <ol>
            <li>Numbered item one</li>
            <li>Numbered item two</li>
        </ol>
        """

    static let replyExample = """
        <p>@username Thanks for sharing! The <code>RichView</code> component looks great.</p>
        <p>I especially like the <strong>syntax highlighting</strong> feature.</p>
        """

    static let errorExample = """
        <p>This contains an unsupported tag:</p>
        <video src="video.mp4">Video content</video>
        <p>This should trigger an error in DEBUG mode.</p>
        """

    static var customStylesheet: RenderStylesheet {
        var stylesheet = RenderStylesheet.default
        stylesheet.body.fontSize = 18
        stylesheet.body.color = Color.purple
        stylesheet.link.color = Color.orange
        stylesheet.link.underline = true
        stylesheet.code.inlineBackgroundColor = Color.yellow.opacity(0.2)
        stylesheet.code.inlineTextColor = Color.brown
        stylesheet.mention.backgroundColor = Color.blue.opacity(0.2)
        stylesheet.mention.textColor = Color.blue
        return stylesheet
    }
}

// MARK: - Interactive Preview

@available(iOS 18.0, *)
struct RichViewInteractivePreview: View {
    @State private var htmlInput = """
        <h2>Interactive RichView Preview</h2>
        <p>Edit the HTML below to see <strong>live rendering</strong>!</p>
        <p>Supports <em>italic</em>, <code>code</code>, and <a href="https://example.com">links</a>.</p>
        <p>Mention users like @johndoe or @alice.</p>
        """

    @State private var selectedStyle: StylePreset = .default

    enum StylePreset: String, CaseIterable {
        case `default` = "Default"
        case compact = "Compact"
        case accessibility = "Accessibility"

        var configuration: RenderConfiguration {
            switch self {
            case .default:
                return .default
            case .compact:
                return .compact
            case .accessibility:
                return RenderConfiguration(stylesheet: .accessibility)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Style selector
            Picker("Style", selection: $selectedStyle) {
                ForEach(StylePreset.allCases, id: \.self) { preset in
                    Text(preset.rawValue).tag(preset)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Rendered view
            ScrollView {
                RichView(htmlContent: htmlInput)
                    .configuration(selectedStyle.configuration)
                    .onLinkTapped { url in
                        print("Link tapped: \(url)")
                    }
                    .onMentionTapped { username in
                        print("Mention tapped: @\(username)")
                    }
                    .onRenderCompleted { metadata in
                        print("Render completed in \(metadata.renderTime)s")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))

            Divider()

            // HTML input
            TextEditor(text: $htmlInput)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .frame(height: 200)
        }
        .navigationTitle("RichView Interactive")
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 18.0, *)
struct RichViewPlayground: View {
    var body: some View {
        NavigationView {
            RichViewInteractivePreview()
        }
    }
}

@available(iOS 18.0, *)
struct RichViewPlayground_Previews: PreviewProvider {
    static var previews: some View {
        RichViewPlayground()
    }
}