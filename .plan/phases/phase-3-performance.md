# Phase 3: Performance Optimization

## 📊 Progress Overview

- **Status**: Not Started
- **Start Date**: TBD
- **End Date**: TBD (actual)
- **Estimated Duration**: 2-3 days
- **Actual Duration**: TBD
- **Completion**: 0/10 tasks (0%)

## 🎯 Goals

Optimize rendering performance for production use:
1. Multi-level caching system (HTML, Markdown, AttributedString)
2. Background thread rendering
3. Lazy image loading
4. Memory management
5. Performance benchmarking

## 📋 Tasks Checklist

### Implementation

- [ ] Implement RichViewCache with NSCache
  - **Estimated**: 3h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Three-tier cache (HTML→Markdown, Markdown→AttributedString, Image URLs)

- [ ] Add cache invalidation strategy
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: LRU eviction, memory pressure handling, manual clear API

- [ ] Implement background rendering with actors
  - **Estimated**: 4h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Swift Actor for thread-safe rendering, main thread for UI updates

- [ ] Add lazy loading for images
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Load images only when visible, cancel on scroll away

- [ ] Optimize AttributedString creation
  - **Estimated**: 3h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Reuse font objects, batch attribute application, avoid redundant conversions

- [ ] Add rendering performance metrics
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: RenderMetadata with timing, cache hits, memory usage

- [ ] Implement automatic task cancellation
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: SwiftUI .task modifier, cancel on view disappear

- [ ] Add memory warning handling
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Clear caches on memory pressure, NotificationCenter observer

### Testing

- [ ] Cache performance tests
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Details**:
    - Test cache hit rate
    - Test cache invalidation
    - Test memory limit enforcement
    - Test concurrent access safety

- [ ] Rendering benchmark tests
  - **Estimated**: 3h
  - **Actual**:
  - **PR**:
  - **Details**:
    - Measure HTML→Markdown conversion time
    - Measure Markdown→AttributedString time
    - Measure end-to-end render time
    - Compare with baseline (HtmlView, RichText)
    - Test with real V2EX content (small, medium, large)

- [ ] Memory profiling tests
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Details**:
    - Measure peak memory usage
    - Test for memory leaks
    - Test cache memory limits
    - Test rapid scroll performance

## 📈 Metrics

### Performance Targets
- **Render Time**: <50ms for typical reply (baseline: RichText ~30ms, HtmlView ~200ms)
- **Cache Hit Rate**: >80% for scrolling scenarios
- **Memory Usage**: <10MB for cache (100 entries)
- **Image Loading**: <100ms for cached images

### Code Quality
- Unit Test Coverage: 0% (target: maintain >85%)
- Performance Tests: 0/3 passing
- Memory Leak Tests: 0/1 passing

### Benchmarks (vs. Baseline)

| Metric | HtmlView | RichText | RichView Target |
|--------|----------|----------|-----------------|
| Render Time | ~200ms | ~30ms | <50ms |
| Memory (per item) | ~2MB | ~50KB | <100KB |
| Scroll FPS | ~30 | ~55 | >55 |
| Cache Support | ✗ | ✗ | ✓ |

### Files Created/Modified
- RichViewCache.swift
- RenderActor.swift
- PerformanceMetrics.swift
- RichView.swift (add caching, background rendering)
- RichViewCacheTests.swift
- RenderPerformanceTests.swift
- MemoryProfileTests.swift

## 🔗 Related

- **PRs**: TBD
- **Issues**: #70
- **Previous Phase**: [phase-2-features.md](phase-2-features.md)
- **Tracking**: [tracking_strategy.md](../tracking_strategy.md)

## 📝 Notes

### Design Decisions
- NSCache over Dictionary (automatic memory management)
- Swift Actor for thread safety (modern concurrency)
- Three-tier cache strategy (maximize reuse)
- SwiftUI .task for automatic cancellation

### Performance Strategy
1. **Cache Layer**: Avoid redundant conversions
2. **Background Rendering**: Keep main thread free
3. **Lazy Loading**: Load only what's visible
4. **Memory Management**: Automatic cleanup on pressure

### Potential Blockers
- Actor isolation complexity
- NSCache tuning for optimal hit rate
- AttributedString thread safety
- Image loading cancellation timing

### Testing Focus
- Real-world V2EX content (from API responses)
- Rapid scrolling scenarios
- Memory pressure simulation
- Cache eviction correctness
- Concurrent access safety

### Baseline Comparison
Need to establish baselines:
- Profile HtmlView render time with Instruments
- Profile RichText render time with Instruments
- Measure FPS during scroll in Feed and FeedDetail
- Record memory usage for 100-item list
