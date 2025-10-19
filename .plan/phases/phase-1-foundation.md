# Phase 1: Foundation

## 📊 Progress Overview

- **Status**: Not Started
- **Start Date**: TBD
- **End Date**: TBD (actual)
- **Estimated Duration**: 2-3 days
- **Actual Duration**: TBD
- **Completion**: 0/10 tasks (0%)

## 🎯 Goals

Build the foundational components of RichView module:
1. HTML to Markdown converter with V2EX-specific handling
2. Markdown to AttributedString renderer with basic styling
3. Basic RichView SwiftUI component with configuration support
4. Unit tests and SwiftUI previews

## 📋 Tasks Checklist

### Implementation

- [ ] Create RichView module directory structure
  - **Estimated**: 30min
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: `Sources/RichView/`, `Models/`, `Converters/`, `Renderers/`

- [ ] Implement HTMLToMarkdownConverter (basic tags)
  - **Estimated**: 3h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Support p, br, strong, em, a, code, pre tags; V2EX URL fixing (// → https://)

- [ ] Implement MarkdownRenderer (basic styles)
  - **Estimated**: 4h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: AttributedString with bold, italic, inline code, links

- [ ] Implement RenderStylesheet system
  - **Estimated**: 3h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: TextStyle, HeadingStyle, LinkStyle, CodeStyle; .default preset with GitHub styling

- [ ] Implement RenderConfiguration
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: crashOnUnsupportedTags flag, stylesheet parameter

- [ ] Create basic RichView component
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: SwiftUI view with htmlContent binding, configuration modifier

- [ ] Implement RenderError with DEBUG crash
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: unsupportedTag case, assertInDebug() helper

### Testing

- [ ] HTMLToMarkdownConverter unit tests
  - **Estimated**: 2h
  - **Actual**:
  - **Coverage**: Target >80%
  - **PR**:
  - **Details**:
    - Test basic tag conversion (p, br, strong, em, a, code, pre)
    - Test V2EX URL fixing (// → https://)
    - Test unsupported tags crash in DEBUG
    - Test text escaping

- [ ] MarkdownRenderer unit tests
  - **Estimated**: 2h
  - **Actual**:
  - **Coverage**: Target >80%
  - **PR**:
  - **Details**:
    - Test AttributedString output for each style
    - Test link attributes
    - Test font application

- [ ] RichView SwiftUI Previews
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**:
    - Basic text with bold/italic
    - Links and inline code
    - Mixed formatting
    - Dark mode variant

## 📈 Metrics

### Code Quality
- Unit Test Coverage: 0% (target: >80%)
- SwiftUI Previews: 0/4 passing
- Compiler Warnings: 0

### Files Created
- HTMLToMarkdownConverter.swift
- MarkdownRenderer.swift
- RenderStylesheet.swift
- RenderConfiguration.swift
- RichView.swift
- RenderError.swift
- RichView+Preview.swift
- HTMLToMarkdownConverterTests.swift
- MarkdownRendererTests.swift

## 🔗 Related

- **PRs**: TBD
- **Issues**: #70
- **Commits**: TBD
- **Tracking**: [tracking_strategy.md](../tracking_strategy.md)

## 📝 Notes

### Design Decisions
- Using swift-markdown as parser (Apple's official library)
- No WebView fallback - all HTML must convert to Markdown
- DEBUG builds crash on unsupported tags to force comprehensive support
- GitHub Markdown styling as default

### Potential Blockers
- swift-markdown learning curve
- V2EX-specific HTML quirks
- AttributedString API limitations

### Testing Focus
- Comprehensive HTML tag coverage
- V2EX URL edge cases
- Crash behavior in DEBUG mode
- AttributedString attribute correctness
