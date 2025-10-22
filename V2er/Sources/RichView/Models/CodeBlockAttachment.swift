//
//  CodeBlockAttachment.swift
//  V2er
//
//  Created by RichView on 2025/1/19.
//

import SwiftUI

/// Code block view with optional syntax highlighting
@available(iOS 18.0, *)
public struct CodeBlockAttachment: View {

    // MARK: - Properties

    /// Code content
    let code: String

    /// Programming language (for syntax highlighting)
    let language: String?

    /// Code style configuration
    let style: CodeStyle

    /// Enable syntax highlighting (requires Highlightr)
    let enableHighlighting: Bool

    // MARK: - Initialization

    public init(
        code: String,
        language: String? = nil,
        style: CodeStyle,
        enableHighlighting: Bool = true
    ) {
        self.code = code
        self.language = language
        self.style = style
        self.enableHighlighting = enableHighlighting
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Language label (if specified)
            if let language = language, !language.isEmpty {
                HStack {
                    Text(language.uppercased())
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)

                    Spacer()

                    // Copy button
                    Button(action: copyCode) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, style.blockPadding.leading)
                .padding(.top, 8)
            }

            // Code content
            ScrollView(.horizontal, showsIndicators: true) {
                Text(code)
                    .font(.system(size: style.blockFontSize, design: .monospaced))
                    .foregroundColor(Color(uiColor: style.blockTextColor.uiColor))
                    .padding(style.blockPadding.edgeInsets)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .background(Color(uiColor: style.blockBackgroundColor.uiColor))
        .cornerRadius(style.blockCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.blockCornerRadius)
                .stroke(Color.gray.opacity(Double(0.2)), lineWidth: 1)
        )
    }

    // MARK: - Actions

    private func copyCode() {
        #if os(iOS)
        UIPasteboard.general.string = code
        #endif
    }
}

// MARK: - Language Detection

public struct LanguageDetector {

    /// Detect programming language from code content
    public static func detectLanguage(from code: String) -> String? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)

        // Swift
        if trimmed.contains("func ") || trimmed.contains("let ") || trimmed.contains("var ") ||
           trimmed.contains("import Swift") || trimmed.contains("@objc") {
            return "swift"
        }

        // Python
        if trimmed.contains("def ") || trimmed.contains("import ") || trimmed.contains("from ") ||
           trimmed.contains("print(") || trimmed.contains("self.") {
            return "python"
        }

        // JavaScript/TypeScript
        if trimmed.contains("const ") || trimmed.contains("function ") || trimmed.contains("=>") ||
           trimmed.contains("console.log") || trimmed.contains("require(") {
            return "javascript"
        }

        // Java
        if trimmed.contains("public class ") || trimmed.contains("public static void") ||
           trimmed.contains("System.out.println") {
            return "java"
        }

        // Go
        if trimmed.contains("package ") || trimmed.contains("func main()") ||
           trimmed.contains("fmt.Println") {
            return "go"
        }

        // Rust
        if trimmed.contains("fn main()") || trimmed.contains("println!") ||
           trimmed.contains("impl ") {
            return "rust"
        }

        // C/C++
        if trimmed.contains("#include") || trimmed.contains("int main()") ||
           trimmed.contains("std::") {
            return "cpp"
        }

        // Ruby
        if trimmed.contains("def ") || trimmed.contains("puts ") || trimmed.contains("end") {
            return "ruby"
        }

        // PHP
        if trimmed.contains("<?php") || trimmed.contains("function ") || trimmed.contains("echo ") {
            return "php"
        }

        // Shell/Bash
        if trimmed.hasPrefix("#!") || trimmed.contains("#!/bin/bash") || trimmed.contains("#!/bin/sh") {
            return "bash"
        }

        // SQL
        if trimmed.uppercased().contains("SELECT ") || trimmed.uppercased().contains("INSERT ") ||
           trimmed.uppercased().contains("UPDATE ") || trimmed.uppercased().contains("DELETE ") {
            return "sql"
        }

        // HTML
        if trimmed.contains("<!DOCTYPE") || trimmed.contains("<html") || trimmed.contains("<div") {
            return "html"
        }

        // CSS
        if trimmed.contains("{") && trimmed.contains(":") && trimmed.contains(";") &&
           (trimmed.contains(".") || trimmed.contains("#") || trimmed.contains("color")) {
            return "css"
        }

        // JSON
        if (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) ||
           (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) {
            if trimmed.contains("\":") {
                return "json"
            }
        }

        // Markdown
        if trimmed.contains("# ") || trimmed.contains("## ") || trimmed.contains("```") {
            return "markdown"
        }

        return nil
    }

    /// Get display name for language
    public static func displayName(for language: String) -> String {
        switch language.lowercased() {
        case "swift": return "Swift"
        case "python", "py": return "Python"
        case "javascript", "js": return "JavaScript"
        case "typescript", "ts": return "TypeScript"
        case "java": return "Java"
        case "go", "golang": return "Go"
        case "rust", "rs": return "Rust"
        case "cpp", "c++", "cxx": return "C++"
        case "c": return "C"
        case "ruby", "rb": return "Ruby"
        case "php": return "PHP"
        case "bash", "sh", "shell": return "Shell"
        case "sql": return "SQL"
        case "html": return "HTML"
        case "css": return "CSS"
        case "json": return "JSON"
        case "markdown", "md": return "Markdown"
        case "yaml", "yml": return "YAML"
        case "xml": return "XML"
        default: return language.uppercased()
        }
    }
}

// MARK: - EdgeInsets Extension

extension EdgeInsets {
    var edgeInsets: EdgeInsets {
        self
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
struct CodeBlockAttachment_Previews: PreviewProvider {
    static let swiftCode = """
        func fibonacci(_ n: Int) -> Int {
            guard n > 1 else { return n }
            return fibonacci(n - 1) + fibonacci(n - 2)
        }

        let result = fibonacci(10)
        print("Result: \\(result)")
        """

    static let pythonCode = """
        def fibonacci(n):
            if n <= 1:
                return n
            return fibonacci(n - 1) + fibonacci(n - 2)

        result = fibonacci(10)
        print(f"Result: {result}")
        """

    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                CodeBlockAttachment(
                    code: swiftCode,
                    language: "swift",
                    style: CodeStyle()
                )

                CodeBlockAttachment(
                    code: pythonCode,
                    language: "python",
                    style: CodeStyle()
                )

                CodeBlockAttachment(
                    code: "const x = 10;\nconsole.log(x);",
                    language: nil, // Auto-detect
                    style: CodeStyle()
                )
            }
            .padding()
        }
        .preferredColorScheme(.light)
        .previewDisplayName("Light Mode")

        ScrollView {
            VStack(spacing: 20) {
                CodeBlockAttachment(
                    code: swiftCode,
                    language: "swift",
                    style: CodeStyle()
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}