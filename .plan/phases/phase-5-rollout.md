# Phase 5: Feature Flag & Gradual Rollout

## 📊 Progress Overview

- **Status**: Not Started
- **Start Date**: TBD
- **End Date**: TBD (actual)
- **Estimated Duration**: 1-2 days
- **Actual Duration**: TBD
- **Completion**: 0/8 tasks (0%)

## 🎯 Goals

Safe, gradual rollout of RichView to production:
1. Implement feature flag system
2. A/B testing infrastructure
3. Gradual rollout (0% → 50% → 100%)
4. Monitoring and rollback capability
5. Production validation
6. Cleanup old implementations

## 📋 Tasks Checklist

### Implementation

- [ ] Create FeatureFlag system
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**:
    - FeatureFlag enum with .useRichView case
    - UserDefaults storage
    - Debug menu override
    - Server-controlled flags (optional)

- [ ] Add RichView toggle in Debug Settings
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Toggle to force enable/disable RichView for testing

- [ ] Implement conditional rendering in NewsContentView
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**:
    ```swift
    if FeatureFlag.useRichView.isEnabled {
        RichView(htmlContent: contentInfo?.html ?? "")
    } else {
        HtmlView(html: contentInfo?.html, ...)
    }
    ```

- [ ] Implement conditional rendering in ReplyItemView
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Same conditional pattern as NewsContentView

- [ ] Add analytics/logging for RichView usage
  - **Estimated**: 2h
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**:
    - Log render success/failure
    - Log performance metrics
    - Log unsupported tag encounters (RELEASE mode)

- [ ] Create rollout plan documentation
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Document rollout stages and criteria

### Testing & Validation

- [ ] TestFlight beta testing (Stage 1: 0%)
  - **Estimated**: 1 day
  - **Actual**:
  - **PR**:
  - **Details**:
    - Deploy with flag disabled
    - Internal testing with debug toggle
    - Verify fallback works
    - Collect baseline metrics

- [ ] TestFlight beta testing (Stage 2: 50%)
  - **Estimated**: 2 days
  - **Actual**:
  - **PR**:
  - **Details**:
    - Enable for 50% of users (random)
    - Monitor crash reports
    - Monitor performance metrics
    - Collect user feedback

- [ ] Production rollout (Stage 3: 100%)
  - **Estimated**: 3 days
  - **Actual**:
  - **PR**:
  - **Details**:
    - Enable for 100% of users
    - Monitor for 3 days
    - Verify metrics improvement
    - Prepare rollback if needed

### Cleanup

- [ ] Remove HtmlView implementation
  - **Estimated**: 30min
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Delete V2er/View/Widget/HtmlView.swift

- [ ] Remove RichText implementation
  - **Estimated**: 30min
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Delete V2er/View/Widget/RichText.swift

- [ ] Remove feature flag code
  - **Estimated**: 30min
  - **Actual**:
  - **PR**:
  - **Commits**:
  - **Details**: Remove conditionals, keep only RichView

- [ ] Update documentation
  - **Estimated**: 1h
  - **Actual**:
  - **PR**:
  - **Details**: Update README, CLAUDE.md to mention RichView

## 📈 Metrics

### Rollout Stages

| Stage | Enabled % | Duration | Criteria to Next Stage |
|-------|-----------|----------|------------------------|
| 0: Dark Launch | 0% | 2 days | No crashes in internal testing |
| 1: Canary | 10% | 2 days | <0.1% crash rate, <5% error rate |
| 2: Half Rollout | 50% | 3 days | Performance ≥ baseline, no major issues |
| 3: Full Rollout | 100% | 3 days | Monitor for stability |
| 4: Cleanup | 100% | 1 day | Remove old code |

### Success Metrics

**Must Improve**:
- Topic render time: <50ms (vs. HtmlView ~200ms)
- Memory usage: <10MB per 100 items (vs. HtmlView ~200MB)

**Must Maintain**:
- Crash rate: <0.1%
- Scroll FPS: >55 (same as RichText)
- Feature parity: 100% (all links, images, mentions work)

**Nice to Have**:
- User feedback: Positive
- Code highlighting adoption: >50% of code blocks viewed

### Monitoring

- [ ] Crash rate tracking (via Xcode Organizer / Crashlytics)
- [ ] Performance metrics collection
- [ ] Error logs analysis (RELEASE mode unsupported tags)
- [ ] User feedback collection (via TestFlight feedback)

### Files Created/Modified
- V2er/State/FeatureFlag.swift (new)
- V2er/View/Settings/DebugSettingsView.swift (add RichView toggle)
- V2er/View/FeedDetail/NewsContentView.swift (add conditional)
- V2er/View/FeedDetail/ReplyItemView.swift (add conditional)
- V2er/View/Widget/HtmlView.swift (delete after Stage 4)
- V2er/View/Widget/RichText.swift (delete after Stage 4)

## 🔗 Related

- **PRs**: TBD
- **Issues**: #70
- **Previous Phase**: [phase-4-integration.md](phase-4-integration.md)
- **Tracking**: [tracking_strategy.md](../tracking_strategy.md)

## 📝 Notes

### Rollout Strategy

**Stage 0: Dark Launch (0%)**
- Deploy with feature flag disabled by default
- Internal testing via debug toggle
- Verify no impact on existing users
- Validate monitoring/logging works

**Stage 1: Canary (10%)**
- Randomly select 10% of users
- Monitor crash reports closely
- Quick rollback capability
- 2-day observation period

**Stage 2: Half Rollout (50%)**
- Increase to 50% if Stage 1 successful
- Broader test coverage
- Performance comparison at scale
- 3-day observation period

**Stage 3: Full Rollout (100%)**
- Enable for all users
- Final monitoring period
- Prepare for cleanup

**Stage 4: Cleanup**
- Remove old HtmlView and RichText
- Remove feature flag conditionals
- Update documentation

### Rollback Plan

If issues detected:
1. **Immediate**: Set feature flag to 0% (server-side or app update)
2. **Short-term**: Fix issues, re-test in Stage 0
3. **Long-term**: If unfixable, keep old implementation, deprecate RichView

### Design Decisions
- Feature flag over compile-time switch (safer, reversible)
- Random % vs. user-based (simpler, no bias)
- Debug toggle for internal testing (developer productivity)
- Keep old code until cleanup stage (safety)

### Potential Blockers
- Crash rate spike in early stages
- Performance worse than expected
- User complaints about missing features
- Unexpected HTML edge cases in production

### Testing Focus
- **Crash Monitoring**: Daily checks in Xcode Organizer
- **Performance**: Compare render times before/after
- **Error Logs**: Check for unsupported tag errors
- **User Feedback**: Review TestFlight feedback

### Success Criteria

**Stage 0 → Stage 1**:
- ✅ No crashes in internal testing
- ✅ All manual tests passed
- ✅ Monitoring infrastructure working

**Stage 1 → Stage 2**:
- ✅ Crash rate <0.1%
- ✅ Render error rate <5%
- ✅ No critical user complaints

**Stage 2 → Stage 3**:
- ✅ Performance ≥ baseline (HtmlView, RichText)
- ✅ No major issues reported
- ✅ Feature parity confirmed

**Stage 3 → Stage 4**:
- ✅ 3 days stable at 100%
- ✅ Metrics show improvement
- ✅ No blocking issues

### Monitoring Checklist

#### Daily Checks (During Rollout)
- [ ] Check Xcode Organizer for crashes
- [ ] Review error logs for unsupported tags
- [ ] Check TestFlight feedback
- [ ] Verify performance metrics
- [ ] Check user complaints on social media

#### Weekly Checks (Post-Rollout)
- [ ] Review cumulative crash reports
- [ ] Analyze performance trends
- [ ] Review error patterns
- [ ] Plan improvements for next release

### Documentation Updates

After successful rollout:
- [ ] Update CLAUDE.md to reference RichView (not HtmlView/RichText)
- [ ] Add RichView to Architecture section
- [ ] Document RichView API for future contributors
- [ ] Add migration notes for similar projects
