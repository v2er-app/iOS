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

    /// Attaches a UIContextMenuInteraction to the tab bar itself and keeps a cached
    /// hit area for the 4th tab ("Me"), so the menu only appears when long-pressing
    /// that tab. This is more reliable than attaching to private UITabBarButton views.
    func attachContextMenu(to tabBar: UITabBar) {
        meTabFrameInTabBar = resolveMeTabFrame(in: tabBar)

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
        menuAnchorPreview()
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        menuAnchorPreview()
    }

    // MARK: - Me Tab Hit Area

    private func resolveMeTabFrame(in tabBar: UITabBar) -> CGRect {
        // Prefer actual item view geometry when we can find it.
        if let frame = meTabFrameFromTabBarSubviews(in: tabBar) {
            return frame.insetBy(dx: -6, dy: -6)
        }

        // Fallback: split the tab bar evenly by item count.
        let count = max(tabBar.items?.count ?? 4, 1)
        let index = min(3, count - 1)
        let width = tabBar.bounds.width / CGFloat(count)
        return CGRect(
            x: CGFloat(index) * width,
            y: 0,
            width: width,
            height: tabBar.bounds.height
        )
    }

    private func meTabFrameFromTabBarSubviews(in tabBar: UITabBar) -> CGRect? {
        let tabBarBounds = tabBar.bounds

        // Search recursively because SwiftUI / newer iOS versions may nest item views.
        let allViews = allDescendants(of: tabBar)
        var candidates = allViews
            .compactMap { view -> UIView? in
                guard view !== tabBar else { return nil }
                let className = String(describing: type(of: view))
                if className.contains("TabBarButton") { return view }
                if className.contains("TabBarItem") { return view }
                return nil
            }
            .filter { view in
                let frame = tabBar.convert(view.bounds, from: view)
                return frame.width > 20 &&
                       frame.height > 20 &&
                       tabBarBounds.intersects(frame) &&
                       !view.isHidden &&
                       view.alpha > 0.01
            }

        if candidates.count < 4 {
            // Fallback to UIControl descendants that look like item containers.
            candidates = allViews
                .compactMap { $0 as? UIControl }
                .filter { control in
                    let frame = tabBar.convert(control.bounds, from: control)
                    return control !== tabBar &&
                           frame.width > 20 &&
                           frame.height > 20 &&
                           tabBarBounds.intersects(frame) &&
                           !control.isHidden &&
                           control.alpha > 0.01
                }
        }

        // Deduplicate equivalent frames produced by nested containers.
        let sorted = candidates
            .map { tabBar.convert($0.bounds, from: $0).integral }
            .sorted { lhs, rhs in
                if abs(lhs.minX - rhs.minX) > 0.5 { return lhs.minX < rhs.minX }
                return lhs.width > rhs.width
            }

        var uniqueFrames: [CGRect] = []
        for frame in sorted {
            let isDuplicate = uniqueFrames.contains { existing in
                abs(existing.minX - frame.minX) < 1 &&
                abs(existing.width - frame.width) < 2 &&
                abs(existing.height - frame.height) < 2
            }
            if !isDuplicate {
                uniqueFrames.append(frame)
            }
        }

        guard uniqueFrames.count >= 4 else { return nil }
        return uniqueFrames[3]
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
        parameters.visiblePath = UIBezierPath(roundedRect: stub.bounds, cornerRadius: 12)

        let target = UIPreviewTarget(container: tabBar, center: CGPoint(x: anchorRect.midX, y: anchorRect.midY))
        return UITargetedPreview(view: stub, parameters: parameters, target: target)
    }

    private func previewAnchorRect(in tabBar: UITabBar) -> CGRect {
        let frame = meTabFrameInTabBar.intersection(tabBar.bounds)
        guard !frame.isNull, !frame.isEmpty else { return .null }

        let anchorWidth = min(max(frame.width - 16, 40), 64)
        let anchorHeight = min(max(frame.height - 14, 28), 44)
        return CGRect(
            x: frame.midX - anchorWidth / 2,
            y: max(frame.minY + 4, 0),
            width: anchorWidth,
            height: anchorHeight
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
