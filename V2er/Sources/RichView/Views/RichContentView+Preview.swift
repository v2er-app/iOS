//
//  RichContentView+Preview.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI

@available(iOS 18.0, *)
struct RichContentView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Basic content with mentions
            RichContentView(htmlContent: Self.mentionExample)
                .configuration(.default)
                .padding()
                .previewDisplayName("Mentions")

            // Code blocks
            RichContentView(htmlContent: Self.codeExample)
                .configuration(.default)
                .padding()
                .previewDisplayName("Code Blocks")

            // Images
            RichContentView(htmlContent: Self.imageExample)
                .configuration(.default)
                .padding()
                .previewDisplayName("Images")

            // Complex content
            RichContentView(htmlContent: Self.complexExample)
                .configuration(.default)
                .padding()
                .previewDisplayName("Complex Content")

            // Dark mode
            RichContentView(htmlContent: Self.complexExample)
                .configuration(.default)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")

            // Compact style
            RichContentView(htmlContent: Self.replyExample)
                .configuration(.compact)
                .padding()
                .previewDisplayName("Compact (Reply)")
        }
    }

    // MARK: - Example Content

    static let mentionExample = """
        <p>Hello @username, thanks for your feedback!</p>
        <p>cc @admin @moderator</p>
        """

    static let codeExample = """
        <h2>Swift Example</h2>
        <pre><code>func fibonacci(_ n: Int) -> Int {
            guard n > 1 else { return n }
            return fibonacci(n - 1) + fibonacci(n - 2)
        }

        let result = fibonacci(10)
        print("Result: \\(result)")</code></pre>

        <h2>Python Example</h2>
        <pre><code>def hello_world():
            print("Hello, World!")

        hello_world()</code></pre>
        """

    static let imageExample = """
        <p>Check out this screenshot:</p>
        <img src="https://www.v2ex.com/static/img/logo.png" alt="V2EX Logo">
        <p>Pretty cool, right?</p>
        """

    static let complexExample = """
        <h1>V2EX 帖子内容示例</h1>

        <p>这是一个包含<strong>多种元素</strong>的<em>示例帖子</em>。</p>

        <h2>代码示例</h2>

        <p>这里是一段 Swift 代码：</p>

        <pre><code>struct User {
            let name: String
            let age: Int

            func greet() {
                print("Hello, \\(name)!")
            }
        }

        let user = User(name: "张三", age: 25)
        user.greet()</code></pre>

        <h2>列表示例</h2>

        <ul>
            <li>第一项</li>
            <li>第二项</li>
            <li>第三项</li>
        </ul>

        <h2>引用</h2>

        <blockquote>
            这是一段引用文字，来自某个用户的回复。
        </blockquote>

        <h2>链接和提及</h2>

        <p>相关讨论请查看 <a href="https://www.v2ex.com/t/123456">这个帖子</a>。</p>

        <p>感谢 @Livid 的分享！cc @admin</p>

        <h2>图片</h2>

        <img src="https://www.v2ex.com/static/img/logo.png" alt="V2EX Logo">

        <p>以上就是示例内容。</p>
        """

    static let replyExample = """
        <p>@原作者 说得对，我也遇到了这个问题。</p>
        <p>我的解决方案是：</p>
        <pre><code>let solution = "使用 RichView 来渲染"</code></pre>
        """
}

// MARK: - Interactive Preview

@available(iOS 18.0, *)
struct RichContentViewInteractive: View {
    @State private var htmlInput = RichContentView_Previews.complexExample
    @State private var selectedStyle: StylePreset = .default

    enum StylePreset: String, CaseIterable {
        case `default` = "Default"
        case compact = "Compact"

        var configuration: RenderConfiguration {
            switch self {
            case .default:
                return .default
            case .compact:
                return .compact
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
                RichContentView(htmlContent: htmlInput)
                    .configuration(selectedStyle.configuration)
                    .onLinkTapped { url in
                        print("Link tapped: \(url)")
                    }
                    .onMentionTapped { username in
                        print("Mention tapped: @\(username)")
                    }
                    .onImageTapped { url in
                        print("Image tapped: \(url)")
                    }
                    .padding()
            }
            .frame(maxHeight: .infinity)
            .background(Color.gray.opacity(0.05))

            Divider()

            // HTML input
            TextEditor(text: $htmlInput)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .frame(height: 200)
        }
        .navigationTitle("RichContentView Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 18.0, *)
struct RichContentViewPlayground: View {
    var body: some View {
        NavigationView {
            RichContentViewInteractive()
        }
    }
}

@available(iOS 18.0, *)
struct RichContentViewPlayground_Previews: PreviewProvider {
    static var previews: some View {
        RichContentViewPlayground()
    }
}