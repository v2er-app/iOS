# Phase 4: Integration & Migration

## 📊 Progress Overview

- **Status**: In Progress
- **Start Date**: 2025-01-19
- **End Date**: TBD (actual)
- **Estimated Duration**: 2-3 days
- **Actual Duration**: TBD
- **Completion**: 0/11 tasks (0%)

## 🎯 Goals

Replace existing implementations with RichView:
1. Migrate NewsContentView from HtmlView to RichView
2. Migrate ReplyItemView from RichText to RichView
3. Maintain existing UI/UX behavior
4. Ensure backward compatibility
5. Comprehensive integration testing

## 📋 Tasks Checklist

### 4.1 Topic Content Migration (NewsContentView)

- [ ] Replace HtmlView with RichView in NewsContentView
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **File**: V2er/View/FeedDetail/NewsContentView.swift:23
  - **Before**: `HtmlView(html: contentInfo?.html, imgs: contentInfo?.imgs ?? [], rendered: $rendered)`
  - **After**: `RichView(htmlContent: contentInfo?.html ?? "").configuration(.default)`

- [ ] Migrate height calculation from HtmlView
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: RichView should provide height via RenderMetadata

- [ ] Test topic content rendering
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Test with real V2EX topics (text, code, images, links)

### 4.2 Reply Content Migration (ReplyItemView)

- [ ] Replace RichText with RichView in ReplyItemView
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **File**: V2er/View/FeedDetail/ReplyItemView.swift:48
  - **Before**: `RichText { info.content }`
  - **After**: `RichView(htmlContent: info.content).configuration(.compact)`

- [ ] Configure compact style for replies
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Smaller fonts, reduced spacing vs topic content

- [ ] Test reply content rendering
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Test with real V2EX replies (mentions, code, quotes)

### 4.3 UI Polishing

- [ ] Match existing NewsContentView UI
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Padding, spacing, background colors

- [ ] Match existing ReplyItemView UI
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Line height, text color, margins

- [ ] Dark mode testing
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Verify all colors adapt correctly

### 4.4 Interaction Features

- [ ] Implement link tap handling
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: onLinkTapped event, handle V2EX internal links, Safari for external

- [ ] Implement @mention tap handling
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: onMentionTapped event, navigate to user profile

- [ ] Implement long-press context menu
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Copy text, share, etc.

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
