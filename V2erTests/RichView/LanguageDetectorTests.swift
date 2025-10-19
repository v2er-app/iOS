//
//  LanguageDetectorTests.swift
//  V2erTests
//
//  Created by RichView on 2025/1/19.
//

import XCTest
@testable import V2er

class LanguageDetectorTests: XCTestCase {

    // MARK: - Swift Detection

    func testSwiftDetection() {
        let swiftCode = """
        func hello() {
            let name = "World"
            print("Hello, \\(name)!")
        }
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: swiftCode), "swift")
    }

    func testSwiftWithImport() {
        let swiftCode = "import Foundation\nvar x = 10"
        XCTAssertEqual(LanguageDetector.detectLanguage(from: swiftCode), "swift")
    }

    // MARK: - Python Detection

    func testPythonDetection() {
        let pythonCode = """
        def hello():
            print("Hello, World!")
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: pythonCode), "python")
    }

    func testPythonWithImport() {
        let pythonCode = "import numpy as np\nfrom scipy import stats"
        XCTAssertEqual(LanguageDetector.detectLanguage(from: pythonCode), "python")
    }

    // MARK: - JavaScript Detection

    func testJavaScriptDetection() {
        let jsCode = """
        const greeting = "Hello";
        console.log(greeting);
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: jsCode), "javascript")
    }

    func testJavaScriptArrowFunction() {
        let jsCode = "const add = (a, b) => a + b;"
        XCTAssertEqual(LanguageDetector.detectLanguage(from: jsCode), "javascript")
    }

    // MARK: - Java Detection

    func testJavaDetection() {
        let javaCode = """
        public class Hello {
            public static void main(String[] args) {
                System.out.println("Hello");
            }
        }
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: javaCode), "java")
    }

    // MARK: - Go Detection

    func testGoDetection() {
        let goCode = """
        package main
        import "fmt"
        func main() {
            fmt.Println("Hello")
        }
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: goCode), "go")
    }

    // MARK: - Rust Detection

    func testRustDetection() {
        let rustCode = """
        fn main() {
            println!("Hello, world!");
        }
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: rustCode), "rust")
    }

    // MARK: - C++ Detection

    func testCppDetection() {
        let cppCode = """
        #include <iostream>
        int main() {
            std::cout << "Hello" << std::endl;
            return 0;
        }
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: cppCode), "cpp")
    }

    // MARK: - Ruby Detection

    func testRubyDetection() {
        let rubyCode = """
        def hello
            puts "Hello, World!"
        end
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: rubyCode), "ruby")
    }

    // MARK: - PHP Detection

    func testPHPDetection() {
        let phpCode = """
        <?php
        echo "Hello, World!";
        ?>
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: phpCode), "php")
    }

    // MARK: - Shell/Bash Detection

    func testBashDetection() {
        let bashCode = """
        #!/bin/bash
        echo "Hello, World!"
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: bashCode), "bash")
    }

    // MARK: - SQL Detection

    func testSQLDetection() {
        let sqlCode = """
        SELECT * FROM users WHERE age > 18;
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: sqlCode), "sql")
    }

    func testSQLUpdate() {
        let sqlCode = "UPDATE users SET name = 'John' WHERE id = 1;"
        XCTAssertEqual(LanguageDetector.detectLanguage(from: sqlCode), "sql")
    }

    // MARK: - HTML Detection

    func testHTMLDetection() {
        let htmlCode = """
        <!DOCTYPE html>
        <html>
        <body>
            <h1>Hello</h1>
        </body>
        </html>
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: htmlCode), "html")
    }

    func testHTMLSimple() {
        let htmlCode = "<div class=\"container\">Content</div>"
        XCTAssertEqual(LanguageDetector.detectLanguage(from: htmlCode), "html")
    }

    // MARK: - CSS Detection

    func testCSSDetection() {
        let cssCode = """
        .container {
            color: blue;
            font-size: 16px;
        }
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: cssCode), "css")
    }

    // MARK: - JSON Detection

    func testJSONDetection() {
        let jsonCode = """
        {
            "name": "John",
            "age": 30
        }
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: jsonCode), "json")
    }

    func testJSONArray() {
        let jsonCode = """
        [
            {"id": 1},
            {"id": 2}
        ]
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: jsonCode), "json")
    }

    // MARK: - Markdown Detection

    func testMarkdownDetection() {
        let markdownCode = """
        # Heading 1
        ## Heading 2
        This is **bold** text.
        ```
        code block
        ```
        """

        XCTAssertEqual(LanguageDetector.detectLanguage(from: markdownCode), "markdown")
    }

    // MARK: - Unknown Language

    func testUnknownLanguage() {
        let unknownCode = "some random text that doesn't match any language"
        XCTAssertNil(LanguageDetector.detectLanguage(from: unknownCode))
    }

    func testEmptyCode() {
        XCTAssertNil(LanguageDetector.detectLanguage(from: ""))
    }

    func testWhitespaceOnly() {
        XCTAssertNil(LanguageDetector.detectLanguage(from: "   \n\t  "))
    }

    // MARK: - Display Name Tests

    func testDisplayNames() {
        XCTAssertEqual(LanguageDetector.displayName(for: "swift"), "Swift")
        XCTAssertEqual(LanguageDetector.displayName(for: "python"), "Python")
        XCTAssertEqual(LanguageDetector.displayName(for: "js"), "JavaScript")
        XCTAssertEqual(LanguageDetector.displayName(for: "typescript"), "TypeScript")
        XCTAssertEqual(LanguageDetector.displayName(for: "cpp"), "C++")
        XCTAssertEqual(LanguageDetector.displayName(for: "go"), "Go")
        XCTAssertEqual(LanguageDetector.displayName(for: "rust"), "Rust")
        XCTAssertEqual(LanguageDetector.displayName(for: "bash"), "Shell")
        XCTAssertEqual(LanguageDetector.displayName(for: "unknown"), "UNKNOWN")
    }

    // MARK: - Ambiguous Cases

    func testAmbiguousJavaScriptVsTypeScript() {
        // JavaScript
        let jsCode = "const x = 10;"
        XCTAssertEqual(LanguageDetector.detectLanguage(from: jsCode), "javascript")

        // TypeScript would need type annotations to distinguish
        // For now, both are detected as JavaScript
    }

    func testAmbiguousCVsCpp() {
        // C code (without C++ features)
        let cCode = """
        #include <stdio.h>
        int main() {
            printf("Hello");
            return 0;
        }
        """

        // Will be detected as cpp since we look for #include
        // which is common to both C and C++
        XCTAssertEqual(LanguageDetector.detectLanguage(from: cCode), "cpp")
    }

    // MARK: - Performance Tests

    func testPerformanceWithLargeCode() {
        let largeCode = String(repeating: "function test() { console.log('test'); }\n", count: 1000)

        measure {
            _ = LanguageDetector.detectLanguage(from: largeCode)
        }
    }

    func testPerformanceWithMultipleDetections() {
        let codes = [
            "func test() { }",
            "def test(): pass",
            "const x = 10;",
            "public class Test { }",
            "package main",
            "fn main() { }",
            "#include <iostream>",
            "def test\n puts 'hello'\n end",
            "<?php echo 'hello'; ?>",
            "#!/bin/bash",
            "SELECT * FROM table;",
            "<html><body></body></html>",
            ".test { color: red; }",
            "{\"key\": \"value\"}",
            "# Heading"
        ]

        measure {
            for code in codes {
                _ = LanguageDetector.detectLanguage(from: code)
            }
        }
    }
}