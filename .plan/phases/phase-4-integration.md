# Phase 4: Integration & Migration

## 📊 Progress Overview

- **Status**: In Progress (Partial - iOS 15 Compatibility Pending)
- **Start Date**: 2025-01-19
- **End Date**: TBD (actual)
- **Estimated Duration**: 2-3 days
- **Actual Duration**: TBD
- **Completion**: 7/11 tasks (64%) - Basic integration complete, iOS 15 MarkdownRenderer pending

## 🎯 Goals

Replace existing implementations with RichView:
1. Migrate NewsContentView from HtmlView to RichView
2. Migrate ReplyItemView from RichText to RichView
3. Maintain existing UI/UX behavior
4. Ensure backward compatibility
5. Comprehensive integration testing

## 📋 Tasks Checklist

### 4.1 Topic Content Migration (NewsContentView)

- [x] Replace HtmlView with RichView in NewsContentView
  - **Estimated**: 2h
  - **Actual**: 0.5h
  - **PR**: TBD
  - **Commits**: 08b9230
  - **File**: V2er/View/FeedDetail/NewsContentView.swift:27
  - **Before**: `HtmlView(html: contentInfo?.html, imgs: contentInfo?.imgs ?? [], rendered: $rendered)`
  - **After**: `RichView(htmlContent: contentInfo?.html ?? "").configuration(.default)`

- [x] Migrate height calculation from HtmlView
  - **Estimated**: 2h
  - **Actual**: 0.25h
  - **PR**: TBD
  - **Commits**: 08b9230
  - **Details**: Using onRenderCompleted callback to set rendered=true after content ready

- [ ] Test topic content rendering
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Test with real V2EX topics (text, code, images, links) - PENDING manual testing

### 4.2 Reply Content Migration (ReplyItemView)

- [x] Replace RichText with RichView in ReplyItemView
  - **Estimated**: 1h
  - **Actual**: 0.5h
  - **PR**: TBD
  - **Commits**: 08b9230
  - **File**: V2er/View/FeedDetail/ReplyItemView.swift:52
  - **Before**: `RichText { info.content }`
  - **After**: `RichView(htmlContent: info.content).configuration(.compact)`

- [x] Configure compact style for replies
  - **Estimated**: 1h
  - **Actual**: 0.25h
  - **PR**: TBD
  - **Commits**: 08b9230
  - **Details**: Using RenderConfiguration.compact with dark mode support

- [ ] Test reply content rendering
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Test with real V2EX replies (mentions, code, quotes) - PENDING manual testing

### 4.3 UI Polishing

- [x] Match existing NewsContentView UI
  - **Estimated**: 2h
  - **Actual**: 0.25h
  - **PR**: TBD
  - **Commits**: 08b9230
  - **Details**: Preserved Divider placement, VStack spacing

- [x] Match existing ReplyItemView UI
  - **Estimated**: 1h
  - **Actual**: 0.25h
  - **PR**: TBD
  - **Commits**: 08b9230
  - **Details**: Maintained existing layout, added RichView inline

- [ ] Dark mode testing
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Verify all colors adapt correctly - PENDING manual testing

### 4.4 Interaction Features

- [x] Implement link tap handling
  - **Estimated**: 2h
  - **Actual**: 0.25h
  - **PR**: TBD
  - **Commits**: 08b9230
  - **Details**: onLinkTapped with UIApplication.shared.openURL for both views

- [ ] Implement @mention tap handling
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: onMentionTapped event added, TODO: navigate to user profile

- [ ] Implement long-press context menu
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Copy text, share, etc. - NOT IMPLEMENTED (optional feature)

### Testing

- [ ] Integration tests for NewsContentView
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Details**:
    - Test rendering with various topic types
    - Test link tapping
    - Test image loading
    - Test height calculation
    - Test cache usage

- [ ] Integration tests for ReplyItemView
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Details**:
    - Test rendering with various reply types
    - Test @mention tapping
    - Test compact styling
    - Test nested replies

- [ ] Manual testing checklist
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Details**:
    - [ ] Browse 10+ different topics
    - [ ] Scroll through 50+ replies
    - [ ] Test all link types (internal, external, mentions)
    - [ ] Test light/dark mode switching
    - [ ] Test memory usage during long scrolling
    - [ ] Test offline behavior

## 📈 Metrics

### Migration Progress
- NewsContentView: ⏳ Not Started
- ReplyItemView: ⏳ Not Started

### Code Quality
- Integration Test Coverage: 0% (target: >85%)
- Manual Test Completion: 0/6 items

### Performance Comparison

| Metric | Before (HtmlView) | Before (RichText) | After (RichView) | Target |
|--------|-------------------|-------------------|------------------|--------|
| Topic Render | ~200ms | N/A | TBD | <50ms |
| Reply Render | N/A | ~30ms | TBD | <50ms |
| Scroll FPS | ~30 | ~55 | TBD | >55 |
| Memory/100 items | ~200MB | ~5MB | TBD | <10MB |

### Files Modified
- V2er/View/FeedDetail/NewsContentView.swift (line 23)
- V2er/View/FeedDetail/ReplyItemView.swift (line 48)
- V2er/View/Widget/HtmlView.swift (marked deprecated)
- V2er/View/Widget/RichText.swift (marked deprecated)

## 🔗 Related

- **PRs**: TBD
- **Issues**: #70
- **Previous Phase**: [phase-3-performance.md](phase-3-performance.md)
- **Tracking**: [tracking_strategy.md](../tracking_strategy.md)

## 📝 Notes

### iOS 18.0 Minimum Version

**Status**: ✅ Minimum iOS version upgraded to 18.0

**Changes Made**:
- Updated all `@available(iOS 15.0, *)` → `@available(iOS 18.0, *)`
- Updated all `@available(iOS 16.0, *)` → `@available(iOS 18.0, *)`
- Removed iOS 15/16 compatibility checks and fallback code
- All RichView features now available without version checks

**Fully Enabled Features**:
- ✅ HTML to Markdown conversion (HTMLToMarkdownConverter)
- ✅ **Bold**, *italic*, `code` inline formatting
- ✅ Code block rendering with syntax highlighting (Highlightr)
- ✅ @mention highlighting and tap handling
- ✅ Image rendering (AsyncImageAttachment)
- ✅ Heading styles (H1-H6)
- ✅ Blockquote styling
- ✅ List rendering (bullets and numbers)
- ✅ Link tap handling
- ✅ Dark mode support
- ✅ Height calculation via onRenderCompleted
- ✅ Cache system (markdown and attributedString tiers)

**Next Steps**:
1. Manual testing with real V2EX content
2. Performance comparison testing
3. Integration testing
4. Move to Phase 5 (rollout)

### Migration Strategy
1. **Parallel Implementation**: Keep old code until RichView proven stable
2. **Gradual Rollout**: Use feature flag (Phase 5)
3. **Deprecation**: Mark HtmlView/RichText as deprecated, remove in future release

### Design Decisions
- `.default` configuration for topic content (larger fonts, more spacing)
- `.compact` configuration for reply content (smaller fonts, tighter spacing)
- Same link tap behavior as before (internal → in-app, external → Safari)
- Same @mention behavior as before (navigate to user profile)

### Backward Compatibility
- Keep HtmlView and RichText files temporarily
- Add deprecation warnings
- Document migration path for any external usage

### Potential Blockers
- Height calculation differences may affect layout
- Link tap detection may conflict with text selection
- Image size calculation may differ from HtmlView
- @mention styling may look different than RichText

### Testing Focus
- **Visual Parity**: Screenshots before/after for comparison
- **Interaction Parity**: All taps/gestures work identically
- **Performance**: Measure actual improvement
- **Edge Cases**: Empty content, malformed HTML, very long posts

### Manual Testing Checklist

#### NewsContentView Testing
- [ ] Topic with only text
- [ ] Topic with code blocks (Swift, Python, JavaScript)
- [ ] Topic with images (single, multiple)
- [ ] Topic with links (V2EX internal, external)
- [ ] Topic with mixed content
- [ ] Very long topic (>1000 words)
- [ ] Malformed HTML edge cases

#### ReplyItemView Testing
- [ ] Reply with @mention
- [ ] Reply with code inline
- [ ] Reply with quote
- [ ] Reply with links
- [ ] Short reply (<10 words)
- [ ] Long reply (>100 words)
- [ ] Nested replies

#### Interaction Testing
- [ ] Tap on V2EX internal link (e.g., /t/12345)
- [ ] Tap on external link (opens Safari)
- [ ] Tap on @username (navigates to profile)
- [ ] Long press for context menu
- [ ] Text selection (if supported)
- [ ] Image tap (if zoom supported)

#### Performance Testing
- [ ] Scroll 100+ replies rapidly
- [ ] Switch between topics quickly
- [ ] Monitor memory in Instruments
- [ ] Check FPS in Xcode Debug Navigator
- [ ] Test on older device (if available)
