//
//  TabBarContextMenuHelper.swift
//  V2er
//
//  Attaches a UIContextMenuInteraction to the tab bar and only enables it
//  within the Me tab hit area
//  for Telegram-style long-press account switching.
//

#if os(iOS)
import SwiftUI
import UIKit
import Kingfisher

// MARK: - Tab Bar Finder View

    /// An invisible UIView embedded via UIViewRepresentable as a `.background` on the TabView.
    /// When added to the window, it walks UP the superview chain to find the UITabBar,
    /// then attaches a UIContextMenuInteraction for the Me tab area.
///
/// This approach is more reliable than searching from the window downward because:
/// 1. We start from a known position inside the SwiftUI-managed UITabBar hierarchy.
/// 2. `didMoveToWindow()` fires exactly when the view is in the hierarchy.
/// 3. Walking up is deterministic; walking down is fragile with SwiftUI's deep nesting.
private class TabBarFinderView: UIView {
    var onTabBarFound: ((UITabBar) -> Void)?
    private var retryCount = 0
    private static let maxRetries = 20

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        attemptFind()
    }

    /// Attempts to find the UITabBar and its buttons.
    /// If the tab bar exists but buttons aren't laid out yet, retries after a short delay.
    private func attemptFind() {
        guard let window = self.window else { return }

        if let tabBar = Self.findSubview(ofType: UITabBar.self, in: window) {
            // Check that tab bar buttons are actually laid out
            let buttons = tabBar.subviews.filter { $0 is UIControl }
            if buttons.count >= 4 {
                onTabBarFound?(tabBar)
                return
            }
        }

        // Tab bar or its buttons may not exist yet; retry up to ~2 seconds
        guard retryCount < Self.maxRetries else { return }
        retryCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.attemptFind()
        }
    }

    /// Recursive depth-first search for a view of a specific type.
    fileprivate static func findSubview<T: UIView>(ofType type: T.Type, in view: UIView) -> T? {
        if let match = view as? T { return match }
        for sub in view.subviews {
            if let found = findSubview(ofType: type, in: sub) { return found }
        }
        return nil
    }
}

/// SwiftUI wrapper for `TabBarFinderView`. Place this as a `.background` on a TabView.
struct TabBarContextMenuAttacher: UIViewRepresentable {
    let accountManager: AccountManager
    let onSwitch: (String) -> Void
    let onAddAccount: () -> Void
    let onManageAccounts: () -> Void

    func makeUIView(context: Context) -> UIView {
        let finder = TabBarFinderView()
        // Use alpha=0 instead of isHidden=true to prevent SwiftUI from optimizing the view away
        finder.alpha = 0
        finder.isUserInteractionEnabled = false
        // Non-zero frame ensures SwiftUI keeps this view in the hierarchy
        finder.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        finder.onTabBarFound = { [weak coordinator = context.coordinator] tabBar in
            coordinator?.attachContextMenu(to: tabBar)
        }
        return finder
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the coordinator's callbacks so closures stay fresh
        context.coordinator.accountManager = accountManager
        context.coordinator.onSwitch = onSwitch
        context.coordinator.onAddAccount = onAddAccount
        context.coordinator.onManageAccounts = onManageAccounts

        // Re-attempt attachment if needed (e.g., after a trait collection change
        // or if the first attempt failed because the tab bar wasn't ready).
        if let finder = uiView as? TabBarFinderView {
            finder.onTabBarFound = { [weak coordinator = context.coordinator] tabBar in
                coordinator?.attachContextMenu(to: tabBar)
            }
            // Trigger a re-check on each SwiftUI state update
            if let window = uiView.window,
               let tabBar = TabBarFinderView.findSubview(ofType: UITabBar.self, in: window) {
                context.coordinator.attachContextMenu(to: tabBar)
            }
        }
    }

    func makeCoordinator() -> TabBarMenuCoordinator {
        TabBarMenuCoordinator(
            accountManager: accountManager,
            onSwitch: onSwitch,
            onAddAccount: onAddAccount,
            onManageAccounts: onManageAccounts
        )
    }
}

// MARK: - Context Menu Coordinator

final class TabBarMenuCoordinator: NSObject, UIContextMenuInteractionDelegate {
    var accountManager: AccountManager
    var onSwitch: (String) -> Void
    var onAddAccount: () -> Void
    var onManageAccounts: () -> Void

    private weak var attachedTabBar: UITabBar?
    private var previewStubView: UIView?
    private var menuInteraction: UIContextMenuInteraction?
    private var meTabFrameInTabBar: CGRect = .zero

    init(
        accountManager: AccountManager,
        onSwitch: @escaping (String) -> Void,
        onAddAccount: @escaping () -> Void,
        onManageAccounts: @escaping () -> Void
    ) {
        self.accountManager = accountManager
        self.onSwitch = onSwitch
        self.onAddAccount = onAddAccount
        self.onManageAccounts = onManageAccounts
    }

    /// Attaches a UIContextMenuInteraction to the tab bar and filters by the Me tab hit area.
    /// This path is the most reliable for long-press triggering across iOS versions.
    func attachContextMenu(to tabBar: UITabBar) {
        let geometry = resolveMeTabGeometry(in: tabBar)
        meTabFrameInTabBar = geometry.frame

        // Already attached to this visible tab bar
        if let current = attachedTabBar,
           current === tabBar,
           current.window != nil,
           menuInteraction != nil {
            return
        }

        // Clean up old interaction
        if let old = menuInteraction {
            attachedTabBar?.removeInteraction(old)
        }

        let interaction = UIContextMenuInteraction(delegate: self)
        tabBar.addInteraction(interaction)
        menuInteraction = interaction
        attachedTabBar = tabBar
    }

    // MARK: - UIContextMenuInteractionDelegate

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard meTabFrameInTabBar.contains(location) else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            self?.buildMenu() ?? UIMenu(title: "", children: [])
        }
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        // Invisible anchor preview used only to position the menu over the Me tab.
        menuAnchorPreview()
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        // Avoid any flash/ghost rectangle on action tap.
        nil
    }

    // MARK: - Me Tab Hit Area

    private func resolveMeTabGeometry(in tabBar: UITabBar) -> (frame: CGRect, interactionView: UIView?) {
        // Prefer actual item view geometry when we can find it.
        if let candidate = meTabCandidateFromTabBarSubviews(in: tabBar) {
            return (candidate.frame.insetBy(dx: -6, dy: -6), candidate.view)
        }

        // Fallback: split the tab bar evenly by item count.
        let count = max(tabBar.items?.count ?? 4, 1)
        let index = min(3, count - 1)
        let width = tabBar.bounds.width / CGFloat(count)
        return (
            CGRect(
                x: CGFloat(index) * width,
                y: 0,
                width: width,
                height: tabBar.bounds.height
            ),
            nil
        )
    }

    private func meTabCandidateFromTabBarSubviews(in tabBar: UITabBar) -> (view: UIView, frame: CGRect)? {
        let tabBarBounds = tabBar.bounds
        let allViews = allDescendants(of: tabBar)

        func collectControls(matchingClassName: Bool) -> [(view: UIView, frame: CGRect)] {
            allViews.compactMap { rawView -> (view: UIView, frame: CGRect)? in
                guard let control = rawView as? UIControl, control !== tabBar else { return nil }
                let className = String(describing: type(of: control))
                if matchingClassName && !className.contains("TabBarButton") {
                    return nil
                }

                let frame = tabBar.convert(control.bounds, from: control)
                guard frame.width > 20,
                      frame.height > 20,
                      tabBarBounds.intersects(frame),
                      !control.isHidden,
                      control.alpha > 0.01,
                      control.isUserInteractionEnabled else {
                    return nil
                }
                return (control, frame.integral)
            }
        }

        var candidates = collectControls(matchingClassName: true)
        if candidates.count < 4 {
            candidates = collectControls(matchingClassName: false)
        }

        // Deduplicate nested/overlapping controls and sort left-to-right.
        let sorted = candidates.sorted { lhs, rhs in
            if abs(lhs.frame.minX - rhs.frame.minX) > 0.5 { return lhs.frame.minX < rhs.frame.minX }
            return lhs.frame.width > rhs.frame.width
        }

        var uniqueCandidates: [(view: UIView, frame: CGRect)] = []
        for candidate in sorted {
            let isDuplicate = uniqueCandidates.contains { existing in
                abs(existing.frame.minX - candidate.frame.minX) < 1 &&
                abs(existing.frame.midY - candidate.frame.midY) < 4 &&
                abs(existing.frame.width - candidate.frame.width) < 4
            }
            if !isDuplicate {
                uniqueCandidates.append(candidate)
            }
        }

        guard uniqueCandidates.count >= 4 else { return nil }
        return uniqueCandidates[3]
    }

    private func allDescendants(of view: UIView) -> [UIView] {
        var result: [UIView] = [view]
        for subview in view.subviews {
            result.append(contentsOf: allDescendants(of: subview))
        }
        return result
    }

    private func menuAnchorPreview() -> UITargetedPreview? {
        guard let tabBar = attachedTabBar else { return nil }
        let anchorRect = previewAnchorRect(in: tabBar)
        guard !anchorRect.isNull, !anchorRect.isEmpty else { return nil }

        let stub: UIView
        if let existing = previewStubView {
            stub = existing
        } else {
            let newView = UIView(frame: .zero)
            newView.backgroundColor = .clear
            newView.isOpaque = false
            previewStubView = newView
            stub = newView
        }
        stub.frame = CGRect(origin: .zero, size: anchorRect.size)

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        // No visiblePath: keep the preview visually invisible while preserving the menu anchor point.

        let target = UIPreviewTarget(container: tabBar, center: CGPoint(x: anchorRect.midX, y: anchorRect.midY))
        return UITargetedPreview(view: stub, parameters: parameters, target: target)
    }

    private func previewAnchorRect(in tabBar: UITabBar) -> CGRect {
        let frame = meTabFrameInTabBar.intersection(tabBar.bounds)
        guard !frame.isNull, !frame.isEmpty else { return .null }

        // Small anchor near the tab's center works well without showing any highlight.
        let size = CGSize(width: 4, height: 4)
        return CGRect(
            x: frame.midX - size.width / 2,
            y: frame.midY - size.height / 2,
            width: size.width,
            height: size.height
        ).integral
    }

    private func buildMenu() -> UIMenu {
        let isLoggedIn = AccountState.hasSignIn()

        guard isLoggedIn else {
            let login = UIAction(
                title: "登录",
                image: UIImage(systemName: "person.crop.circle.badge.plus")
            ) { [weak self] _ in
                DispatchQueue.main.async { self?.onAddAccount() }
            }
            return UIMenu(title: "", children: [login])
        }

        var accountActions: [UIMenuElement] = []

        if let current = accountManager.currentAccount {
            let avatar = cachedAvatar(for: current.avatar)
            let action = UIAction(title: current.username, image: avatar, state: .on) { _ in }
            accountActions.append(action)
        }

        let others = accountManager.accounts.filter { $0.username != accountManager.activeUsername }
        for account in others {
            let avatar = cachedAvatar(for: account.avatar)
            let action = UIAction(title: account.username, image: avatar) { [weak self] _ in
                DispatchQueue.main.async { self?.onSwitch(account.username) }
            }
            accountActions.append(action)
        }

        var managementActions: [UIAction] = []

        managementActions.append(UIAction(
            title: "添加账号",
            image: UIImage(systemName: "plus.circle")
        ) { [weak self] _ in
            DispatchQueue.main.async { self?.onAddAccount() }
        })

        if !others.isEmpty {
            managementActions.append(UIAction(
                title: "账号管理",
                image: UIImage(systemName: "person.2")
            ) { [weak self] _ in
                DispatchQueue.main.async { self?.onManageAccounts() }
            })
        }

        let accountMenu = UIMenu(title: "", options: .displayInline, children: accountActions)
        let managementMenu = UIMenu(title: "", options: .displayInline, children: managementActions)

        return UIMenu(title: "", children: [accountMenu, managementMenu])
    }

    // MARK: - Avatar Loading

    private func cachedAvatar(for urlString: String) -> UIImage? {
        let placeholder = UIImage(systemName: "person.circle.fill")
        guard let url = URL(string: urlString) else { return placeholder }

        let cache = ImageCache.default
        let key = url.absoluteString

        if let cached = cache.retrieveImageInMemoryCache(forKey: key) {
            return circularImage(cached, size: 24)
        }

        if cache.isCached(forKey: key),
           let data = try? cache.diskStorage.value(forKey: key),
           let image = UIImage(data: data) {
            return circularImage(image, size: 24)
        }

        return placeholder
    }

    private func circularImage(_ image: UIImage, size: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { _ in
            UIBezierPath(ovalIn: rect).addClip()
            image.draw(in: rect)
        }
    }
}
#endif
