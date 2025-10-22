# RichView Implementation Tracking Strategy

## 📊 Overview

RichView 的实现将跨越多个 PR，持续 10-12 天。我们需要一个清晰的追踪系统来管理进度。

---

## 🎯 Tracking Levels

### Level 1: GitHub Issue #70 (Master Tracking)
- **用途**: 整体项目进度鸟瞰
- **更新频率**: 每完成一个 Phase
- **负责人**: 自己
- **内容**: Phase-level checkboxes (5 个主要阶段)

### Level 2: Phase Markdown Files (Detailed Tracking)
- **用途**: 每个 Phase 的详细任务列表
- **更新频率**: 每完成一个子任务
- **位置**: `.plan/phases/phase-{N}.md`
- **内容**: 详细的 task checkboxes + 测试要求

### Level 3: Individual PRs (Implementation Evidence)
- **用途**: 代码实现和 Review
- **命名规范**: `feat(richview): Phase N - {description}`
- **内容**: 实际代码 + 测试 + Preview
- **关联**: PR description 链接到 Phase markdown file

### Level 4: Git Commit Messages (Granular History)
- **用途**: 代码变更历史
- **格式**: Conventional Commits
- **Examples**:
  - `feat(richview): implement HTMLToMarkdownConverter basic tags`
  - `test(richview): add unit tests for HTML parsing`
  - `docs(richview): add SwiftUI preview for code highlighting`

---

## 📁 File Structure

```
.plan/
├── richtext_plan.md           # 技术设计文档
├── richview_api.md            # API 定义文档
├── tracking_strategy.md       # 本文档 (追踪策略)
└── phases/                    # Phase 追踪目录
    ├── phase-1-foundation.md      # Phase 1 详细追踪
    ├── phase-2-features.md        # Phase 2 详细追踪
    ├── phase-3-performance.md     # Phase 3 详细追踪
    ├── phase-4-integration.md     # Phase 4 详细追踪
    └── phase-5-rollout.md         # Phase 5 详细追踪
```

---

## 📝 Phase Tracking File Format

每个 Phase 的 markdown 文件格式：

```markdown
# Phase {N}: {Name}

## 📊 Progress Overview

- **Status**: Not Started | In Progress | Completed
- **Start Date**: YYYY-MM-DD
- **End Date**: YYYY-MM-DD (actual)
- **Estimated Duration**: X days
- **Actual Duration**: X days
- **Completion**: 0/10 tasks (0%)

## 🎯 Goals

{Phase goals from technical plan}

## 📋 Tasks Checklist

### Implementation
- [ ] Task 1
  - **Estimated**: 2h
  - **Actual**:
  - **PR**: #XX
  - **Commits**: abc1234, def5678
- [ ] Task 2
  ...

### Testing
- [ ] Unit test 1
  - **Coverage**: 85%
  - **PR**: #XX
- [ ] Preview 1
  ...

## 📈 Metrics

### Code Quality
- Unit Test Coverage: XX%
- SwiftUI Previews: X/X passing

### Performance (if applicable)
- Render Time: XXms
- Memory Usage: XXMB
- Cache Hit Rate: XX%

## 🔗 Related

- **PRs**: #XX, #YY
- **Issues**: #70
- **Commits**: [link to compare view]

## 📝 Notes

{Any issues, blockers, or important decisions}
```

---

## 🔄 Workflow

### Starting a Phase

1. **Update Phase Markdown**
   ```bash
   # Update status and start date
   vim .plan/phases/phase-1-foundation.md
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/richview-phase-1
   ```

3. **Update Issue #70**
   - Comment: "Starting Phase 1: Foundation"
   - Link to phase markdown file

### During Development

1. **完成每个任务后**:
   ```bash
   # Mark checkbox in phase markdown
   # Update actual time spent
   # Link PR/commit
   ```

2. **每次 commit**:
   ```bash
   git commit -m "feat(richview): implement basic HTML converter

   - Support p, br, strong, em, a, code, pre tags
   - V2EX URL fixing (// → https://)
   - Basic text escaping

   Progress: Phase 1, Task 3/10

   Refs: .plan/phases/phase-1-foundation.md"
   ```

3. **创建 PR**:
   ```markdown
   ## Phase 1: Foundation - HTML Conversion

   This PR implements the basic HTML to Markdown converter.

   ### Tasks Completed
   - [x] Basic tag support
   - [x] URL fixing
   - [x] Text escaping

   ### Testing
   - [x] Unit tests (coverage: 85%)
   - [x] Manual testing with real V2EX content

   ### Progress
   Phase 1: 3/10 tasks (30%)

   See: `.plan/phases/phase-1-foundation.md`
   Tracking: #70
   ```

### Completing a Phase

1. **验证 Phase Checklist**
   - 确保所有 tasks 完成
   - 确保所有测试通过
   - 更新 metrics

2. **Update Phase Markdown**
   ```markdown
   - **Status**: Completed
   - **End Date**: 2025-01-20
   - **Actual Duration**: 2.5 days
   - **Completion**: 10/10 tasks (100%)
   ```

3. **Update Issue #70**
   - Check off Phase checkbox
   - Comment with summary and metrics
   - Link to PRs

4. **Create Summary Comment**
   ```markdown
   ## ✅ Phase 1 Completed

   **Duration**: 2.5 days (estimated: 2-3 days)

   ### Achievements
   - ✅ HTML to Markdown converter (8 tags)
   - ✅ Markdown to AttributedString renderer
   - ✅ Basic RichView component
   - ✅ Unit test coverage: 82%
   - ✅ 3 SwiftUI previews

   ### Metrics
   - Tests: 25 passing
   - Coverage: 82%
   - Lines of code: ~800

   ### PRs
   - #71: HTML Converter
   - #72: Markdown Renderer
   - #73: RichView Component

   **Next**: Phase 2 - Complete Features

   See details: `.plan/phases/phase-1-foundation.md`
   ```

---

## 🏷️ PR Naming Convention

Format: `feat(richview): Phase {N} - {description}`

Examples:
- `feat(richview): Phase 1 - implement HTML to Markdown converter`
- `feat(richview): Phase 1 - add Markdown renderer with basic styles`
- `test(richview): Phase 1 - add unit tests for HTML parsing`
- `docs(richview): Phase 1 - add SwiftUI previews for basic elements`
- `feat(richview): Phase 2 - add code syntax highlighting`
- `feat(richview): Phase 2 - implement async image loading`

---

## 📊 Progress Reporting

### Daily Standup Format (Optional)

```markdown
## RichView Progress - 2025-01-20

### Yesterday
- ✅ Completed HTMLToMarkdownConverter
- ✅ Added unit tests (coverage: 85%)

### Today
- 🔄 Implementing MarkdownRenderer
- 🔄 Adding SwiftUI previews

### Blockers
- None

### Phase 1 Progress: 6/10 tasks (60%)
```

### Weekly Summary Format

```markdown
## RichView Week 1 Summary

### Completed
- ✅ Phase 1: Foundation (100%)
  - HTMLToMarkdownConverter
  - MarkdownRenderer
  - Basic RichView component
  - Unit tests (82% coverage)

### In Progress
- 🔄 Phase 2: Features (30%)
  - Code highlighting
  - Image support

### Next Week
- Complete Phase 2
- Start Phase 3 (performance)

### Metrics
- Total PRs: 3 merged, 2 open
- Test coverage: 82%
- Lines added: ~1,200
```

---

## 🎯 Issue #70 Updates

### Format for Phase Completion Comments

```markdown
## ✅ Phase {N} Completed: {Name}

**Duration**: {actual} days (estimated: {estimate} days)
**PRs**: #{X}, #{Y}, #{Z}
**Status**: ✅ All tasks completed

### Summary
{Brief description of what was accomplished}

### Deliverables
- ✅ {Deliverable 1}
- ✅ {Deliverable 2}
- ✅ {Deliverable 3}

### Metrics
- **Test Coverage**: XX%
- **Tests Added**: XX passing
- **Lines of Code**: ~XXX
- **Performance**: {if applicable}

### Key Decisions
{Any important technical decisions made during this phase}

### Challenges & Solutions
{Any blockers encountered and how they were resolved}

**Next**: Phase {N+1} - {Name}
**Details**: `.plan/phases/phase-{N}-{name}.md`

---

{Checkbox list updated in issue body}
```

---

## 🔍 Finding Information Quickly

### By Phase
```bash
# View specific phase progress
cat .plan/phases/phase-2-features.md

# List all phase files
ls .plan/phases/
```

### By Task
```bash
# Search for specific task across all phases
grep -r "AsyncImageAttachment" .plan/phases/
```

### By Metric
```bash
# Find test coverage for all phases
grep -r "Coverage:" .plan/phases/
```

### By PR
```bash
# Find which phase a PR belongs to
git log --oneline | grep "Phase 2"
```

---

## 📈 Metrics Dashboard (Manual)

Create a simple metrics file that gets updated after each phase:

```markdown
# RichView Metrics Dashboard

## Overall Progress
- **Phase 1**: ✅ Completed (2.5 days)
- **Phase 2**: 🔄 In Progress (1.5 days elapsed)
- **Phase 3**: ⏳ Not Started
- **Phase 4**: ⏳ Not Started
- **Phase 5**: ⏳ Not Started

**Overall**: 15% (1.5/10 days)

## Code Quality
- **Total Test Coverage**: 82%
- **Total Tests**: 25 passing, 0 failing
- **Total Lines**: ~1,200
- **SwiftUI Previews**: 3/8

## Performance (Phase 3+)
- **Render Time**: N/A
- **Memory Usage**: N/A
- **Cache Hit Rate**: N/A

## PRs
- **Merged**: 3
- **Open**: 2
- **Total**: 5

Last updated: 2025-01-20
```

---

## 🚀 Automation Opportunities

### Git Hooks (Optional)

Create `.git/hooks/commit-msg` to enforce commit format:

```bash
#!/bin/bash
commit_msg=$(cat "$1")

# Check for Phase reference
if ! echo "$commit_msg" | grep -qE "Phase [1-5]"; then
    echo "Warning: Commit message doesn't reference a Phase"
    echo "Consider adding 'Progress: Phase N, Task X/Y'"
fi
```

### GitHub Actions (Future)

- Auto-update Issue #70 when PR is merged
- Calculate test coverage and post as comment
- Generate progress report weekly

---

## 📱 Quick Reference

### Checklist Before Starting Work
1. [ ] Branch name: `feature/richview-phase-{N}`
2. [ ] Phase markdown status: "In Progress"
3. [ ] Issue #70 commented: "Starting Phase {N}"

### Checklist Before Creating PR
1. [ ] All related tasks checked off in phase markdown
2. [ ] Tests written and passing
3. [ ] SwiftUI previews added (if applicable)
4. [ ] PR description references phase markdown
5. [ ] PR title follows naming convention

### Checklist After Completing Phase
1. [ ] Phase markdown: Status = "Completed"
2. [ ] Phase markdown: All metrics updated
3. [ ] Issue #70: Phase checkbox checked
4. [ ] Issue #70: Summary comment posted
5. [ ] All PRs merged

---

## 🎯 Success Criteria

A phase is considered complete when:

1. ✅ All implementation tasks checked off
2. ✅ All test requirements met (coverage targets)
3. ✅ All SwiftUI previews working
4. ✅ All verification criteria passed
5. ✅ Phase markdown fully updated
6. ✅ Issue #70 updated
7. ✅ All PRs merged to feature branch

---

*Last updated: 2025-01-19*
