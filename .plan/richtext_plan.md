# V2er-iOS RichText 渲染重构技术设计

## 📌 项目概述

### 背景

当前 V2er-iOS 在两个地方使用不同的方式渲染 V2EX HTML 内容，都存在性能和功能问题：

#### 1. 帖子内容（NewsContentView）
- **实现**: `HtmlView` - 基于 WKWebView
- **问题**:
  - 性能开销大，WebView 初始化慢
  - 内存占用高（每个 WebView ~20MB）
  - 高度计算延迟，导致界面跳动
  - JavaScript 桥接复杂，维护困难

#### 2. 回复列表（ReplyItemView）
- **实现**: `RichText` - 基于 NSAttributedString HTML 解析
- **问题**:
  - 不支持代码语法高亮
  - 不支持 @mention 识别和跳转
  - 不支持图片预览交互
  - 渲染效果与帖子内容不一致

#### 统一问题
- 两套实现维护成本高
- 功能不一致，用户体验割裂
- 都缺少缓存机制
- 都不支持完整的 V2EX 特性（@mention、代码高亮等）

### 目标

使用统一的 **RichView** 模块替换现有的两套实现：
- ✅ 统一渲染引擎: HTML → Markdown → swift-markdown + Highlightr
- ✅ 统一交互体验: @mention、图片预览、代码高亮
- ✅ 统一配置管理: 支持不同场景的样式配置（帖子 vs 回复）
- ✅ 统一缓存策略: 自动缓存，提升列表滚动性能

### 预期收益

#### 性能提升
- **帖子内容**: 10x+ 渲染速度（WKWebView → Native）
- **回复列表**: 3-5x 渲染速度（支持缓存 + 优化）
- **内存优化**: 减少 70%+ 内存占用（移除 WebView）
- **滚动流畅**: 60fps 稳定帧率，无卡顿

#### 功能增强
- **代码高亮**: 支持 185+ 编程语言语法高亮
- **@mention**: 自动识别并支持点击跳转
- **图片预览**: 内置图片查看器，支持手势缩放
- **一致体验**: 帖子和回复使用相同渲染效果

#### 开发体验
- **统一 API**: 一套代码适用于所有场景
- **易于维护**: 移除 WebView 和 JavaScript 桥接
- **类型安全**: Swift 原生实现，编译时检查
- **可扩展**: 模块化设计，易于添加新功能

---

## 🏗️ 架构设计

### 整体流程

```
> `RenderMetadata` 用于记录渲染耗时、图片资源等信息；`html.md5` 由 `String+Markdown.swift` 提供的扩展负责生成缓存键。

```swift
struct RenderMetadata {
    let generatedAt: Date
    let renderTime: TimeInterval
    let imageCount: Int
    let cacheHit: Bool
}
```
V2EX API Response (HTML)
         ↓
    SwiftSoup 解析
         ↓
HTMLToMarkdownConverter (清洗 + 转换)
         ↓
    Markdown String
         ↓
swift-markdown 解析 (生成 AST)
         ↓
   Document (AST)
         ↓
CustomMarkupVisitor (遍历 + 渲染)
         ↓
  AttributedString
         ↓
RichTextUIView (UITextViewRepresentable) / SwiftUI Text 降级显示
```

### 为什么需要 Markdown → AttributedString 转换？

#### SwiftUI Text 的 Markdown 支持局限性

虽然 SwiftUI 的 `Text` 视图原生支持基础 Markdown 渲染：

```swift
Text("**Bold** and *italic* and [link](https://example.com)")
```

但它**无法满足** V2EX 内容的渲染需求：

| 功能需求 | SwiftUI Text + Markdown | 我们的方案 (AttributedString) |
|---------|------------------------|------------------------------|
| 基础文本格式 | ✅ 支持 | ✅ 支持 |
| 普通链接 | ⚠️ 只能打开 URL | ✅ 可拦截处理 |
| @提及跳转 | ❌ 不支持 | ✅ 自定义跳转 |
| 图片显示 | ❌ 完全不渲染 | ✅ 异步加载 + 预览 |
| 代码高亮 | ❌ 只有等宽字体 | ✅ 语法高亮 |
| 文本选择 | ✅ 支持 | ✅ 支持 |
| 自定义样式 | ❌ 不可控 | ✅ 完全自定义 |

#### 架构设计理由

**1. 为什么要转换为 Markdown（而不是直接 HTML → AttributedString）？**

- **复杂度分离**: HTML 解析（处理标签混乱）与渲染逻辑（样式交互）分离
- **标准化中间格式**: Markdown 作为清洗后的标准格式，便于调试和缓存
- **利用 Apple 生态**: swift-markdown 是官方库，性能和稳定性有保障
- **扩展性**: 未来可直接支持 Markdown 输入，不仅限于 HTML

**2. 为什么需要 AttributedString（而不是直接渲染 Markdown）？**

- **自定义交互**: 需要拦截链接点击，实现 @提及跳转、图片预览等
- **图片附件**: 只有 NSTextAttachment 才能实现异步图片加载
- **代码高亮**: 需要为不同语法元素设置不同颜色和样式
- **性能优势**: AttributedString 渲染性能优于多个 SwiftUI View 组合

**3. 每一层的具体职责**

```
1. HTML (原始内容)
   "<a href='/member/user'>@user</a> <img src='...'>"

2. HTMLToMarkdownConverter (清洗标准化)
   "[@user](@mention:user) ![image](https://...)"
   职责: 清理无用标签、修正 URL、转换为标准格式

3. swift-markdown Parser (结构化解析)
   Document { Link("@mention:user"), Image("https://...") }
   职责: 生成可遍历的 AST 结构

4. V2EXMarkupVisitor (自定义渲染)
   AttributedString with custom attributes
   职责: 为每个元素添加样式、交互属性

5. 最终展示
   可点击、可交互、支持异步加载的富文本
```

### 核心模块

#### 1. HTMLToMarkdownConverter (HTML 转换层)
- **职责**: 将 V2EX HTML 清洗并转换为 Markdown
- **输入**: HTML String
- **输出**: Markdown String
- **依赖**: SwiftSoup

#### 2. MarkdownRenderer (Markdown 渲染层)
- **职责**: 解析 Markdown 并生成 AttributedString
- **输入**: Markdown String
- **输出**: AttributedString
- **依赖**: swift-markdown, Highlightr

#### 3. V2EXMarkupVisitor (自定义访问器)
- **职责**: 遍历 Markdown AST，构建富文本
- **输入**: Document (AST)
- **输出**: AttributedString
- **依赖**: Markdown framework

#### 4. AsyncImageAttachment (图片附件)
- **职责**: 异步加载图片并显示
- **输入**: Image URL
- **输出**: NSTextAttachment with Image
- **依赖**: Kingfisher

#### 5. V2EXRichTextView (SwiftUI 视图)
- **职责**: SwiftUI 视图组件，处理交互
- **输入**: HTML String
- **输出**: 可交互的富文本视图
- **依赖**: SwiftUI, UIKit

---

## 🔧 技术实现细节

### 1. HTML 标签映射

| HTML 标签 | Markdown 语法 | 说明 |
|-----------|--------------|------|
| `<p>`, `<div>` | 段落 + 空行 | 块级元素 |
| `<br>` | `  \n` | 行内换行 |
| `<strong>`, `<b>` | `**text**` | 加粗 |
| `<em>`, `<i>` | `*text*` | 斜体 |
| `<code>` | `` `code` `` | 行内代码 |
| `<pre><code>` | ` ```lang\ncode\n``` ` | 代码块 |
| `<a href="">` | `[text](url)` | 链接 |
| `<img src="">` | `![alt](url)` | 图片 |
| `<blockquote>` | `> quote` | 引用 |
| `<ul><li>` | `- item` | 无序列表 |
| `<ol><li>` | `1. item` | 有序列表 |
| `<hr>` | `---` | 分割线 |
| `<h1>` - `<h6>` | `#` - `######` | 标题 |

### 2. V2EX 特殊处理

#### @提及用户
- **HTML**: `<a href="/member/username">@username</a>`
- **转换**: `[@username](@mention:username)`
- **渲染**: 蓝色加粗，可点击跳转到用户页面

#### 图片处理
- **URL 修正**: `//i.v2ex.co/` → `https://i.v2ex.co/`
- **异步加载**: 使用 AsyncImageAttachment 延迟加载
- **点击事件**: 支持点击预览大图
- **链接包裹**: 图片如果被 `<a>` 包裹，保留链接信息

#### 代码高亮
- **语言检测**: 从 `class="language-swift"` 提取语言
- **自动检测**: 分析代码内容推断语言
- **Highlightr**: 使用 highlight.js 引擎高亮
- **主题**: 支持 Light/Dark 模式主题切换

### 3. 性能优化策略

#### 缓存机制
```swift
final class RenderCache {
    final class AttributedStringWrapper: NSObject {
        let value: AttributedString
        let metadata: RenderMetadata

        init(value: AttributedString, metadata: RenderMetadata) {
            self.value = value
            self.metadata = metadata
        }
    }

    // L1: 内存缓存，持有引用类型包装的 NSAttributedString
    private let memoryCache = NSCache<NSString, AttributedStringWrapper>()

    // L2: 磁盘缓存 (可选)
    private let diskCache: DiskCache?

    // 缓存 Key: HTML 的 MD5
    func get(_ html: String) -> AttributedString? {
        memoryCache.object(forKey: html.md5 as NSString)?.value
    }

    func set(_ html: String, _ result: AttributedString, metadata: RenderMetadata) {
        let wrapper = AttributedStringWrapper(value: result, metadata: metadata)
        memoryCache.setObject(wrapper, forKey: html.md5 as NSString)
    }
}
```

#### 异步渲染
```swift
renderTask?.cancel()
renderTask = Task(priority: .userInitiated) {
    let result = try await renderer.render(html)
    guard !Task.isCancelled else { return }
    await MainActor.run { self.attributedString = result }
}
```

#### 增量加载
- 可见区域优先渲染
- 预渲染相邻 5 条内容
- 滚动时动态加载

---

## 📦 依赖管理

### Swift Package Manager 依赖

```swift
dependencies: [
    // Apple 官方 Markdown 解析
    .package(
        url: "https://github.com/apple/swift-markdown.git",
        from: "0.3.0"
    ),

    // 代码语法高亮
    .package(
        url: "https://github.com/raspu/Highlightr.git",
        from: "2.1.0"
    ),

    // HTML 解析 (已有)
    // SwiftSoup

    // 图片加载 (已有)
    // Kingfisher
]
```

---

## 🗂️ 模块化文件结构

### RichView 独立模块设计

将所有富文本渲染相关代码集中在 `RichView` 模块下，实现完全自包含、高内聚的模块化设计。

```
V2er/
└── View/
    └── RichView/                           # 独立模块根目录 ⭐
        │
        ├── RichView.swift                  # 公开接口（模块入口）
        │   - public struct RichView: View
        │   - 对外暴露的唯一视图组件
        │
        ├── Components/                     # 视图组件层
        │   ├── RichTextView.swift         # UITextView 包装（内部）
        │   └── AsyncImageAttachment.swift  # 异步图片附件
        │
        ├── Rendering/                      # 渲染引擎层
        │   ├── HTMLToMarkdownConverter.swift  # HTML → Markdown
        │   ├── MarkdownRenderer.swift          # Markdown → AttributedString
        │   └── V2EXMarkupVisitor.swift         # AST 遍历器
        │
        ├── Support/                        # 支持功能层
        │   ├── RenderCache.swift          # 缓存管理
        │   ├── DegradationChecker.swift   # 降级检测
        │   └── PerformanceBenchmark.swift # 性能测试
        │
        ├── Models/                         # 数据模型
        │   ├── RichViewEvent.swift        # 事件定义
        │   ├── RenderConfiguration.swift  # 配置模型
        │   └── RenderMetadata.swift       # 渲染元数据
        │
        └── Extensions/                     # 扩展工具
            ├── AttributedString+RichView.swift
            └── String+Markdown.swift

V2erTests/                                  # 测试目录
└── RichView/
    ├── HTMLToMarkdownConverterTests.swift
    ├── MarkdownRendererTests.swift
    ├── RenderCacheTests.swift
    └── RichViewIntegrationTests.swift
```

### 模块化设计原则

#### 1. 访问控制层次

```swift
// ✅ Public (对外接口)
public struct RichView: View { }
public enum RichViewEvent { }
public struct RenderConfiguration { }

// ✅ Internal (模块内部)
internal struct RichTextView: UIViewRepresentable { }
internal class HTMLToMarkdownConverter { }
internal class MarkdownRenderer { }

// ✅ Fileprivate (文件内部)
fileprivate class AttributedStringWrapper: NSObject { }
```

#### 2. 公开接口示例

```swift
// RichView.swift - 唯一对外接口
public struct RichView: View {
    let htmlContent: String
    let configuration: RenderConfiguration
    var onEvent: ((RichViewEvent) -> Void)?

    public init(
        htmlContent: String,
        configuration: RenderConfiguration = .default,
        onEvent: ((RichViewEvent) -> Void)? = nil
    ) {
        self.htmlContent = htmlContent
        self.configuration = configuration
        self.onEvent = onEvent
    }

    public var body: some View {
        RichTextView(
            htmlContent: htmlContent,
            configuration: configuration,
            onEvent: onEvent
        )
    }
}

// 外部使用示例
RichView(htmlContent: post.content) { event in
    switch event {
    case .linkTapped(let url):
        openURL(url)
    case .imageTapped(let url):
        showImagePreview(url)
    case .mentionTapped(let username):
        navigateToUser(username)
    }
}
```

### 模块化优势

| 优势 | 说明 |
|------|------|
| **高内聚** | 所有相关代码集中在 RichView/ 目录 |
| **低耦合** | 通过公开接口与外部交互，内部实现随时可修改 |
| **可测试** | 独立的测试目录，完整的单元测试覆盖 |
| **可复用** | 可轻松移植到其他项目或开源发布 |
| **易维护** | 职责清晰，修改不影响其他模块 |
| **版本控制** | 可独立管理版本（如 RichView v1.0） |

### 依赖关系

```
外部代码
    ↓ (只依赖公开接口)
RichView.swift (public)
    ↓
Components/ + Rendering/ + Support/
    ↓
Models/ + Extensions/
```

---

## 🎯 实施计划

### Phase 1: 基础架构 (2-3天)

**目标**: 实现核心转换和渲染逻辑

**任务**:
- [ ] 创建 RichView 模块目录结构
  - [ ] `V2er/View/RichView/` 根目录
  - [ ] `Components/` 组件层子目录
  - [ ] `Rendering/` 渲染引擎子目录
  - [ ] `Support/` 支持功能子目录
  - [ ] `Models/` 数据模型子目录
  - [ ] `Extensions/` 扩展工具子目录
- [ ] 集成 SPM 依赖 (swift-markdown, Highlightr)
- [ ] 实现 `RichView.swift` 公开接口
  - [ ] 定义 public API
  - [ ] 事件回调接口
- [ ] 实现 `Rendering/HTMLToMarkdownConverter.swift` 基础版本
  - [ ] 支持核心标签: p, br, strong, em, a, code, pre
  - [ ] V2EX URL 修正
  - [ ] 基础文本转义
- [ ] 实现 `Rendering/MarkdownRenderer.swift`
- [ ] 实现 `Rendering/V2EXMarkupVisitor.swift` 基础版本
  - [ ] 处理文本、加粗、斜体
  - [ ] 处理链接
  - [ ] 处理代码块 (无高亮)
- [ ] 实现 `Components/RichTextView.swift` 基础 UITextView 包装

**TDD 测试要求**:
- [ ] **HTMLToMarkdownConverter 单元测试**
  - [ ] 测试基础标签转换 (p, br, strong, em, a, code, pre)
  - [ ] 测试 V2EX URL 修正 (// → https://)
  - [ ] 测试文本转义 (特殊字符)
  - [ ] 测试空内容和 nil 处理
  - [ ] 测试不支持的标签 (DEBUG 模式应crash)
- [ ] **MarkdownRenderer 单元测试**
  - [ ] 测试基础 Markdown → AttributedString
  - [ ] 测试加粗、斜体渲染
  - [ ] 测试链接渲染
  - [ ] 测试代码块渲染 (无高亮)
  - [ ] 测试空 Markdown 处理
- [ ] **SwiftUI Preview**
  - [ ] 创建 RichView_Previews with 基础示例
  - [ ] 验证文本、加粗、斜体显示
  - [ ] 验证链接点击区域
  - [ ] Dark mode 预览

**验收标准**:
- ✅ 能够正确转换简单的 V2EX HTML
- ✅ 能够显示基础文本格式
- ✅ 链接可点击
- ✅ 单元测试覆盖率 > 80%
- ✅ SwiftUI Preview 正常显示

### Phase 2: 完整功能 (3-4天)

**目标**: 实现所有功能和交互

**任务**:
- [ ] 完善 `Rendering/HTMLToMarkdownConverter.swift`
  - [ ] 支持所有标签: img, blockquote, ul, ol, li, hr, h1-h6
  - [ ] @提及识别和转换
  - [ ] 图片链接包裹处理
- [ ] 完善 `Rendering/V2EXMarkupVisitor.swift`
  - [ ] 图片渲染 (占位图)
  - [ ] 列表渲染
  - [ ] 引用渲染
- [ ] 实现 `Components/AsyncImageAttachment.swift`
  - [ ] Kingfisher 集成
  - [ ] 异步加载
  - [ ] 占位图和失败处理
- [ ] 实现代码高亮
  - [ ] Highlightr 集成到 V2EXMarkupVisitor
  - [ ] 语言检测
  - [ ] Light/Dark 主题
- [ ] 完善 `Components/RichTextView.swift`
  - [ ] UITextView 事件代理
  - [ ] 事件处理 (链接、图片、@提及)
  - [ ] 高度自适应
- [ ] 实现 `Models/RichViewEvent.swift` 事件模型
- [ ] 实现 `Models/RenderConfiguration.swift` 配置模型
- [ ] 实现 `Models/RenderStylesheet.swift` 样式配置模型

**TDD 测试要求**:
- [ ] **HTMLToMarkdownConverter 完整测试**
  - [ ] 测试图片标签转换 (img src 修正, alt属性)
  - [ ] 测试 @提及转换 (`<a href="/member/xxx">` → `[@xxx](@mention:xxx)`)
  - [ ] 测试列表转换 (ul, ol, li, 嵌套列表)
  - [ ] 测试blockquote转换
  - [ ] 测试标题转换 (h1-h6)
  - [ ] 测试图片链接包裹 (`<a><img></a>`)
  - [ ] 测试混合内容 (图片+文本+代码)
- [ ] **V2EXMarkupVisitor 完整测试**
  - [ ] 测试图片 NSTextAttachment 创建
  - [ ] 测试列表缩进和符号
  - [ ] 测试引用样式应用
  - [ ] 测试代码高亮 (多种语言)
  - [ ] 测试 @mention 样式和属性
- [ ] **AsyncImageAttachment 测试**
  - [ ] Mock Kingfisher 测试异步加载
  - [ ] 测试占位图显示
  - [ ] 测试加载失败处理
  - [ ] 测试图片尺寸限制
- [ ] **RichTextView 交互测试**
  - [ ] 测试链接点击事件
  - [ ] 测试图片点击事件
  - [ ] 测试 @mention 点击事件
  - [ ] 测试文本选择
- [ ] **SwiftUI Preview 完整示例**
  - [ ] 代码高亮 Preview (多种语言)
  - [ ] 图片加载 Preview
  - [ ] 列表和引用 Preview
  - [ ] @mention Preview
  - [ ] 复杂混合内容 Preview
  - [ ] 自定义样式 Preview

**验收标准**:
- ✅ 所有 HTML 标签正确转换和显示
- ✅ 代码高亮正常工作 (测试至少 5 种语言)
- ✅ 图片异步加载显示
- ✅ 所有交互事件正常响应
- ✅ 单元测试覆盖率 > 85%
- ✅ SwiftUI Preview 涵盖所有元素类型

### Phase 3: 性能优化 (2-3天)

**目标**: 优化性能，添加缓存

**任务**:
- [ ] 实现 `Support/RenderCache.swift`
  - [ ] NSCache 内存缓存
  - [ ] AttributedStringWrapper (NSObject 包装)
  - [ ] MD5 缓存 Key (通过 Extensions/String+Markdown.swift)
  - [ ] 缓存策略 (LRU)
- [ ] 移除降级逻辑 (不需要 WebView fallback)
  - [ ] 所有标签必须支持
  - [ ] 不支持的标签在 DEBUG 下 crash
  - [ ] RELEASE 下 catch 错误并记录
- [ ] 实现 `Support/PerformanceBenchmark.swift`
  - [ ] 渲染耗时测量
  - [ ] 内存占用监控
  - [ ] 缓存命中率统计
- [ ] 实现 `Models/RenderMetadata.swift`
  - [ ] 渲染时间戳
  - [ ] 性能指标记录
- [ ] 异步渲染优化
  - [ ] 使用 .task modifier (结构化并发)
  - [ ] 优先级控制 (.userInitiated)
- [ ] 性能测试
  - [ ] 渲染速度测试
  - [ ] 内存占用测试
  - [ ] 滚动性能测试
- [ ] 边界情况处理
  - [ ] 空内容
  - [ ] 超长内容
  - [ ] 特殊字符

**TDD 测试要求**:
- [ ] **RenderCache 单元测试**
  - [ ] 测试缓存存取 (set/get)
  - [ ] 测试 MD5 key 生成
  - [ ] 测试缓存淘汰 (LRU)
  - [ ] 测试线程安全 (并发读写)
  - [ ] 测试缓存统计 (hit rate)
- [ ] **PerformanceBenchmark 测试**
  - [ ] 测试渲染时间测量准确性
  - [ ] 测试内存占用监控
  - [ ] 测试缓存命中率计算
- [ ] **性能压力测试**
  - [ ] 100 个不同内容连续渲染 (测试缓存)
  - [ ] 超长内容渲染 (10KB+ HTML)
  - [ ] 复杂内容渲染 (图片+代码+列表混合)
  - [ ] 列表滚动性能 (100+ items, 60fps)
- [ ] **错误处理测试**
  - [ ] DEBUG 模式: 不支持标签 crash 测试
  - [ ] RELEASE 模式: 错误 catch 测试
  - [ ] 空内容处理测试
  - [ ] 损坏 HTML 处理测试

**验收标准**:
- ✅ 缓存命中率 > 80%
- ✅ 渲染速度 < 50ms (单条回复)
- ✅ 内存占用减少 70%+ (vs HtmlView)
- ✅ 流畅滚动 (60fps, 100+ items)
- ✅ 性能测试通过 (自动化)
- ✅ 错误处理符合 DEBUG/RELEASE 策略

### Phase 4: 集成与测试 (2-3天)

**目标**: 集成到现有项目的两个使用场景，实现统一渲染

**任务**:

#### 4.1 替换帖子内容渲染（NewsContentView）
- [ ] 将 `HtmlView` 替换为 `RichView`
  - [ ] 移除 `imgs` 参数（自动从 HTML 提取）
  - [ ] 使用 `.default` 配置
  - [ ] 实现事件处理（链接、图片、@mention）
  - [ ] 保留 `rendered` 状态绑定
- [ ] Feature Flag 控制
  - [ ] 添加 `useRichViewForTopic` 开关
  - [ ] 降级逻辑：失败时回退到 HtmlView
- [ ] 测试
  - [ ] 纯文本帖子
  - [ ] 包含图片的帖子
  - [ ] 包含代码的帖子
  - [ ] 包含 @mention 的帖子
  - [ ] 混合内容帖子

#### 4.2 替换回复内容渲染（ReplyItemView）
- [ ] 将 `RichText` (Atributika) 替换为 `RichView`
  - [ ] 使用 `.compact` 配置（更小字体、更紧凑间距）
  - [ ] 实现事件处理
  - [ ] 适配回复列表布局
- [ ] Feature Flag 控制
  - [ ] 添加 `useRichViewForReply` 开关
  - [ ] 降级逻辑：失败时回退到 RichText
- [ ] 性能测试
  - [ ] 回复列表滚动流畅度（60fps）
  - [ ] 缓存命中率监控
  - [ ] 内存占用对比测试
- [ ] 测试
  - [ ] 短回复（< 100 字符）
  - [ ] 长回复（> 1000 字符）
  - [ ] 包含代码的回复
  - [ ] 包含 @mention 的回复
  - [ ] 列表滚动性能（100+ 回复）

#### 4.3 UI 适配
- [ ] 字体大小适配
  - [ ] 帖子内容: fontSize = 16
  - [ ] 回复内容: fontSize = 14（compact 配置）
- [ ] Dark Mode 适配
  - [ ] 文本颜色自动适配
  - [ ] 代码高亮主题切换
  - [ ] 链接颜色适配
- [ ] 行距和段距调整
  - [ ] 与现有 UI 保持一致
  - [ ] 适配不同屏幕尺寸

#### 4.4 交互功能测试
- [ ] 链接点击
  - [ ] 外部链接在浏览器打开
  - [ ] 内部链接应用内导航
- [ ] 图片预览
  - [ ] 单击显示图片查看器
  - [ ] 支持手势缩放
  - [ ] 支持关闭
- [ ] @mention 跳转
  - [ ] 点击跳转到用户主页
  - [ ] 正确解析用户名
- [ ] 文本选择
  - [ ] 支持长按选择
  - [ ] 支持复制

#### 4.5 降级测试
- [ ] 超大内容降级（>100KB）
- [ ] 包含不支持标签的内容降级
- [ ] 渲染错误时降级
- [ ] 验证降级后功能正常

**验收标准**:
- ✅ 帖子内容和回复内容均使用 RichView
- ✅ 所有交互功能正常工作
- ✅ UI 与现有设计一致
- ✅ 回复列表滚动流畅（60fps）
- ✅ 缓存命中率 > 80%
- ✅ 降级方案可用且功能完整
- ✅ 无明显性能或内存问题

### Phase 5: 发布与监控 (1天)

**目标**: 灰度发布，监控线上表现

**任务**:
- [ ] Feature Flag 配置
  - [ ] 默认关闭
  - [ ] 逐步放量 (10% → 50% → 100%)
- [ ] 性能监控
  - [ ] 渲染耗时统计
  - [ ] 崩溃监控
  - [ ] 用户反馈收集
- [ ] 问题修复
  - [ ] 收集 Bug 反馈
  - [ ] 快速修复
- [ ] 完全替换
  - [ ] 移除 WebView 代码
  - [ ] 清理旧资源

**验收标准**:
- 100% 用户使用新方案
- 崩溃率无明显上升
- 用户反馈正面
- 性能指标达标

---

## 🧪 测试策略

### 单元测试

```swift
class HTMLToMarkdownConverterTests: XCTestCase {
    func testConvertBasicHTML() { }
    func testConvertLinks() { }
    func testConvertImages() { }
    func testConvertCodeBlocks() { }
    func testConvertMentions() { }
    func testEdgeCases() { }
}

class MarkdownRendererTests: XCTestCase {
    func testRenderBasicMarkdown() { }
    func testRenderWithImages() { }
    func testRenderWithCode() { }
}
```

### 集成测试

- 真实 V2EX 帖子内容测试
- 各种边界情况测试
- 性能压力测试

### UI 测试

- 滚动性能测试
- 交互响应测试
- 内存泄漏测试

---

## 🎨 UI/UX 设计

### 字体和样式

```swift
struct RenderStyle {
    // 文本
    let fontSize: CGFloat = 16
    let lineSpacing: CGFloat = 6
    let paragraphSpacing: CGFloat = 12

    // 链接
    let linkColor: Color = .systemBlue
    let mentionColor: Color = .systemBlue

    // 代码
    let codeFont: Font = .system(.monospaced, size: 14)
    let codeBackground: Color = .secondarySystemBackground
    let codePadding: CGFloat = 4

    // 引用
    let quoteLeftBorder: CGFloat = 4
    let quotePadding: CGFloat = 12
    let quoteBackground: Color = .systemGray6
}
```

### Dark Mode 适配

- 背景色自动切换
- 代码高亮主题切换 (GitHub Light/Dark)
- 图片反色处理 (可选)

### 动画效果

- 图片加载渐显动画
- 点击反馈动画
- 内容展开动画 (可选)

---

## 🐛 已知问题与解决方案

### 1. 为什么不使用其他方案？

**SwiftUI Text + Markdown 字符串**
- ❌ 无法显示图片
- ❌ 无法自定义链接点击行为
- ❌ 不支持代码语法高亮
- ❌ 不支持 @提及等自定义语法

**直接使用 NSAttributedString(HTML)**
- ❌ 性能极差（比 swift-markdown 慢 ~1000x）
- ❌ 样式不可控
- ❌ 难以添加自定义交互

**使用 MarkdownUI 等第三方库**
- ❌ 每个元素是独立 View，性能不如 AttributedString
- ❌ 难以实现文本选择和复制
- ❌ 依赖第三方维护

### 2. 复杂 HTML 丢失信息

**问题**: 某些复杂 HTML 转换为 Markdown 可能丢失样式

**解决方案**:
- 保留 WebView 作为降级方案
- 检测无法转换的内容，自动降级
- 逐步扩展支持的 HTML 标签

### 3. 图片加载性能

**问题**: 大量图片异步加载可能影响性能

**解决方案**:
- 图片懒加载，可见区域优先
- Kingfisher 缓存和预加载
- 缩略图优先，点击查看原图

### 4. 代码高亮主题

**问题**: Highlightr 主题可能与应用风格不一致

**解决方案**:
- 自定义 CSS 主题
- 与设计师协作调整
- 提供主题配置选项

### 5. 自定义交互实现

**问题**: SwiftUI Text 不支持自定义 URL Scheme

**解决方案**:
```swift
// 使用 AttributedString + 自定义属性
attributedString.customAction = "mention"
attributedString.link = URL(string: "v2ex://member/username")

// 在 Text 中拦截处理
Text(attributedString)
    .environment(\.openURL, OpenURLAction { url in
        handleCustomURL(url)
        return .handled
    })
```

---

## 📊 性能指标

### 目标指标

| 指标 | 当前 (WebView) | 目标 (swift-markdown) | 测量方法 |
|------|---------------|---------------------|---------|
| 渲染时间 | ~200ms | <50ms | Instruments Time Profiler |
| 内存占用 | ~50MB (10条) | <15MB (10条) | Xcode Memory Graph |
| 滚动帧率 | ~45fps | 60fps | Instruments Core Animation |
| 首屏显示 | ~500ms | <100ms | 手动计时 |

### 监控方案

```swift
struct PerformanceMetrics {
    let renderTime: TimeInterval
    let memoryUsage: UInt64
    let cacheHitRate: Double
    let scrollFPS: Double
}

class PerformanceMonitor {
    static func track(_ metrics: PerformanceMetrics) {
        // 上报到分析平台
    }
}
```

---

## 🔒 风险评估与应对

### 高风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| 复杂内容渲染错误 | 高 | 中 | WebView 降级方案 |
| 性能不达预期 | 高 | 低 | 性能优化，缓存策略 |
| 图片加载失败 | 中 | 中 | 占位图，重试机制 |

### 中风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| 第三方库兼容性 | 中 | 低 | 固定版本，测试覆盖 |
| 内存泄漏 | 中 | 低 | Instruments 检测 |
| UI 适配问题 | 低 | 中 | UI 测试，设计复审 |

---

## 📚 参考资料

### 官方文档
- [swift-markdown Documentation](https://github.com/apple/swift-markdown)
- [cmark-gfm Specification](https://github.github.com/gfm/)
- [AttributedString Documentation](https://developer.apple.com/documentation/foundation/attributedstring)

### 第三方库
- [Highlightr GitHub](https://github.com/raspu/Highlightr)
- [SwiftSoup Documentation](https://github.com/scinfu/SwiftSoup)
- [Kingfisher Documentation](https://github.com/onevcat/Kingfisher)

### 参考项目
- [V2exOS](https://github.com/isaced/V2exOS) - MarkdownUI 实现
- [V2ex-Swift](https://github.com/Finb/V2ex-Swift) - NSAttributedString 实现
- [ChatGPT SwiftUI](https://github.com/alfianlosari/ChatGPTSwiftUI) - Markdown 渲染

---

## ✅ 验收标准

### 功能验收
- [ ] 所有 V2EX HTML 标签正确显示
- [ ] 链接点击正常跳转
- [ ] 图片加载和点击预览
- [ ] @提及点击跳转用户页面
- [ ] 代码高亮正确显示
- [ ] 文本可选择和复制

### 性能验收
- [ ] 渲染速度 <50ms
- [ ] 内存减少 70%+
- [ ] 滚动 60fps
- [ ] 缓存命中率 >80%

### 质量验收
- [ ] 无严重 Bug
- [ ] 单元测试覆盖率 >70%
- [ ] UI 与设计稿一致
- [ ] Dark Mode 正常

---

## 📝 变更日志

### v1.2.0 (2025-01-19)
- 响应 Codex Review，修正 3 个关键阻塞问题
- 修正 AttributedString 缓存类型（使用 NSObject 包装器）
- 明确主视图为 UITextView，Text 仅作降级
- 修正并发模式，禁用 Task.detached
- 添加性能基线测量和阶段性 KPI
- 细化 WebView 降级策略和埋点方案
- 最低支持版本调整为 iOS 17

### v1.1.0 (2025-01-19)
- 添加架构设计理由详细说明
- 解释为什么需要 Markdown → AttributedString 转换
- 补充 SwiftUI Text Markdown 限制说明
- 添加各方案对比和选择理由

### v1.0.0 (2025-01-19)
- 初始技术设计文档
- 定义架构和实施计划
- 设定性能目标和验收标准

---

*Generated on 2025-01-19*
*Last Updated: 2025-01-19 v1.2.0*

---

## Review Notes from Codex (2025-01-19)

### 阻塞项
- 无新增阻塞问题。上一轮指出的缓存类型、视图容器与并发模型已在正文修正，实现阶段保持一致即可。

### 后续建议
- 在缓存章节明确磁盘缓存的容量与淘汰策略，并说明线程安全处理方式，便于实现层对齐。
- 性能指标可区分"首次渲染"和"缓存命中"两类场景，分别列出目标值，便于上线监控。
- Feature Flag 发布章节可追加"默认灰度范围/时间表"，便于渐进式发布执行。

### 开放事项
- 最低支持版本调整为 iOS 17。请在 `V2er/Config/Version.xcconfig`、Fastlane 脚本及发布说明中同步更新，并评估是否需要对旧设备给出说明或降级方案。

---

## 📋 Codex Review 响应与修正 (2025-01-19)

### 阻塞项修正

#### 1. AttributedString 缓存类型问题 ⭐⭐⭐⭐⭐

**问题**：`AttributedString` 是值类型（struct），无法直接放入 `NSCache<NSString, AnyObject>`

**修正方案**：使用 NSObject 包装器

```swift
final class RenderCache {
    final class AttributedStringWrapper: NSObject {
        let value: AttributedString
        let metadata: RenderMetadata

        init(value: AttributedString, metadata: RenderMetadata) {
            self.value = value
            self.metadata = metadata
        }
    }

    private let cache = NSCache<NSString, AttributedStringWrapper>()

    func get(_ key: String) -> AttributedString? {
        cache.object(forKey: key as NSString)?.value
    }

    func set(_ key: String, _ value: AttributedString, metadata: RenderMetadata) {
        cache.setObject(AttributedStringWrapper(value: value, metadata: metadata),
                        forKey: key as NSString)
    }
}
```

**优点**：
- 保留完整的 AttributedString 类型和属性
- 可同时缓存渲染元数据（耗时、图片数量、命中状态）
- 利用 NSCache 的自动内存管理

#### 2. Text vs UITextView 视图混淆 ⭐⭐⭐⭐⭐

**问题**：
- `Text(AttributedString)` 无法渲染 `NSTextAttachment`（图片不显示）
- `Text` 缺少自定义点击处理和手势控制

**修正方案**：明确视图层次结构

**主视图**：`UITextView` (via UIViewRepresentable)
```swift
struct V2EXRichTextView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delegate = context.coordinator
        // ✅ 支持图片附件 (NSTextAttachment)
        // ✅ 支持自定义点击处理
        // ✅ 支持文本选择
        return textView
    }
}
```

**降级视图**：`Text(AttributedString)` (仅纯文本场景)
```swift
// 仅用于无图片、无自定义交互的简单文本
if isSimpleText && !hasImages {
    Text(attributedString)
} else {
    V2EXRichTextView(htmlContent: content)  // ✅ 主方案
}
```

**架构更新**：
```
AttributedString (with NSTextAttachment)
         ↓
   UITextView (主方案) ✅
         ├─ 支持图片附件
         ├─ 支持自定义点击
         ├─ 支持文本选择
         └─ UITextViewDelegate 处理交互

   或 (降级)
         ↓
   SwiftUI Text (纯文本场景)
         ├─ 无图片
         └─ 基础链接跳转
```

#### 3. Task.detached 生命周期问题 ⭐⭐⭐⭐

**问题**：
- `Task.detached` 脱离视图生命周期，无法自动取消
- 列表滚动时会产生大量未取消的任务
- 可能导致内存泄漏

**错误示例**：
```swift
// ❌ 禁止使用
.task {
    await Task.detached {
        // 即使视图销毁，任务仍在运行
        await heavyRendering()
    }.value
}
```

**修正方案**：使用结构化并发

```swift
// ✅ 推荐做法
struct V2EXRichTextView: View {
    let htmlContent: String
    @State private var attributedString: AttributedString?

    var body: some View {
        Group {
            if let attributedString = attributedString {
                RichTextUIView(attributedString: attributedString)
            } else {
                ProgressView()
            }
        }
        .task {  // ✅ 自动取消
            attributedString = await renderContent()
        }
    }

    private func renderContent() async -> AttributedString {
        await Task(priority: .userInitiated) {
            return await renderer.render(htmlContent)
        }.value
    }
}
```

**并发模式规范**：
```swift
// ✅ 推荐使用
.task { }                    // 视图级别，自动取消
Task { }                     // 结构化并发
async let x = foo()          // 结构化并发

// ❌ 禁止使用
Task.detached { }            // 脱离生命周期
DispatchQueue.global() { }   // 非结构化
```

### 次要建议修正

#### 4. 性能指标基线测量 ⭐⭐⭐

**问题**：50ms 目标较激进，缺少基线数据

**修正方案**：建立阶段性 KPI

| 阶段 | 渲染时间目标 | 对比 WebView | 测试内容 |
|------|------------|-------------|---------|
| Phase 1 (基础) | <200ms | 持平 | 纯文本 + 链接 |
| Phase 2 (完整) | <100ms | 2x 提升 | 含图片 + 代码 |
| Phase 3 (优化) | <50ms | 4x 提升 | 缓存优化后 |

**性能测试框架**：
```swift
class PerformanceBenchmark {
    struct Metrics {
        let renderTime: TimeInterval
        let memoryUsage: UInt64
        let contentLength: Int
        let imageCount: Int
    }

    static func measure(_ html: String, method: String) async -> Metrics {
        let startTime = Date()
        let startMemory = getMemoryUsage()

        // 执行渲染
        let result = await renderer.render(html)

        return Metrics(
            renderTime: Date().timeIntervalSince(startTime),
            memoryUsage: getMemoryUsage() - startMemory,
            contentLength: html.count,
            imageCount: extractImageCount(html)
        )
    }
}
```

#### 5. WebView 降级策略细化 ⭐⭐⭐

**问题**：降级触发条件不明确

**修正方案**：明确降级规则和埋点

```swift
struct DegradationChecker {
    enum DegradationReason {
        case htmlTooLarge(size: Int)        // HTML 超过 100KB
        case unsupportedTags([String])       // 包含不支持的标签
        case conversionFailed(error: Error)  // 转换失败
        case renderingError(error: Error)    // 渲染异常
        case performanceTooSlow(time: TimeInterval) // 超过 500ms
    }

    static func shouldDegrade(_ html: String) -> DegradationReason? {
        // 1. 检查大小
        if html.count > 100_000 {
            return .htmlTooLarge(size: html.count)
        }

        // 2. 检查黑名单标签
        let blacklist = ["<iframe", "<object", "<embed", "<video", "<audio"]
        for tag in blacklist {
            if html.contains(tag) {
                return .unsupportedTags([tag])
            }
        }

        // 3. 尝试转换
        do {
            let _ = try converter.convert(html)
        } catch {
            return .conversionFailed(error: error)
        }

        return nil
    }
}

// 埋点方案
struct DegradationAnalytics {
    static func trackDegradation(
        reason: DegradationChecker.DegradationReason,
        topicId: String
    ) {
        Analytics.track([
            "event": "richtext_degradation",
            "reason": reason.description,
            "topic_id": topicId
        ])
    }
}
```

**监控指标**：
- `degradation_rate`: 降级率（目标 <5%）
- `degradation_by_reason`: 各原因分布
- `avg_render_time_by_method`: 各方案平均渲染时间

### 开放问题响应

**iOS 版本兼容性**：
- ✅ 项目最低版本：**iOS 17.0**
- ✅ swift-markdown 要求：iOS 15.0+（满足）
- ✅ AttributedString 要求：iOS 15.0+（满足）
- ✅ 老设备（iOS 16 及以下）将通过应用内公告提示保持旧版 WebView 展示

### 修正任务清单

**立即修正（阻塞项）**：
- [x] 修正 RenderCache 使用 NSObject 包装器
- [x] 明确文档中主视图为 UITextView
- [x] 移除所有 Task.detached，改用 .task 修饰符
- [x] 更新架构图和代码示例

**短期补充（次要建议）**：
- [x] 添加性能基线测量方法
- [x] 制定阶段性 KPI
- [x] 细化 WebView 降级策略
- [x] 添加埋点方案

---

### Codex Review 评价

Codex 的 Review **非常专业且准确**，发现了 3 个关键阻塞问题：

| 问题 | 严重性 | 影响 | 修正状态 |
|------|--------|------|---------|
| AttributedString 缓存类型 | ⭐⭐⭐⭐⭐ | 编译错误 | ✅ 已修正 |
| Text vs UITextView 混淆 | ⭐⭐⭐⭐⭐ | 功能缺失 | ✅ 已修正 |
| Task.detached 生命周期 | ⭐⭐⭐⭐ | 内存泄漏 | ✅ 已修正 |
| 性能指标基线 | ⭐⭐⭐ | 评估困难 | ✅ 已补充 |
| 降级策略细化 | ⭐⭐⭐ | 监控缺失 | ✅ 已补充 |

所有问题均已分析并提供修正方案，技术设计文档已更新。
