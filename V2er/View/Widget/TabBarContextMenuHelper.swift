//
//  TabBarContextMenuHelper.swift
//  V2er
//
//  Attaches a UIContextMenuInteraction to the UITabBar itself (not individual
//  buttons) and uses the hit-test location to only respond in the Me tab region.
//  This avoids relying on private UITabBarButton internals that may eat gestures.
//

#if os(iOS)
import SwiftUI
import UIKit
import Kingfisher

// MARK: - Tab Bar Finder

private class TabBarFinderView: UIView {
    var onTabBarFound: ((UITabBar) -> Void)?
    private var retryCount = 0
    private static let maxRetries = 30

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        attemptFind()
    }

    private func attemptFind() {
        if let tabBar = resolveTabBar(),
           tabBar.items?.count ?? 0 >= 1,
           tabBar.window != nil,
           !tabBar.bounds.isEmpty {
            onTabBarFound?(tabBar)
            return
        }
        guard retryCount < Self.maxRetries else { return }
        retryCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.attemptFind()
        }
    }

    func currentTabBar() -> UITabBar? { resolveTabBar() }

    private func resolveTabBar() -> UITabBar? {
        if let vc = nearestViewController(), let tb = vc.tabBarController?.tabBar { return tb }
        guard let window = self.window else { return nil }
        return Self.findSubview(ofType: UITabBar.self, in: window)
    }

    private func nearestViewController() -> UIViewController? {
        var r: UIResponder? = self
        while let current = r {
            if let vc = current as? UIViewController { return vc }
            r = current.next
        }
        return nil
    }

    fileprivate static func findSubview<T: UIView>(ofType type: T.Type, in view: UIView) -> T? {
        if let match = view as? T { return match }
        for sub in view.subviews { if let found = findSubview(ofType: type, in: sub) { return found } }
        return nil
    }
}

// MARK: - SwiftUI Bridge

struct TabBarContextMenuAttacher: UIViewRepresentable {
    let accountManager: AccountManager
    let onSwitch: (String) -> Void
    let onAddAccount: () -> Void
    let onManageAccounts: () -> Void

    func makeUIView(context: Context) -> UIView {
        let finder = TabBarFinderView()
        finder.alpha = 0
        finder.isUserInteractionEnabled = false
        finder.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        finder.onTabBarFound = { [weak c = context.coordinator] tabBar in
            c?.attach(to: tabBar)
        }
        return finder
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let c = context.coordinator
        c.accountManager = accountManager
        c.onSwitch = onSwitch
        c.onAddAccount = onAddAccount
        c.onManageAccounts = onManageAccounts

        if let finder = uiView as? TabBarFinderView {
            finder.onTabBarFound = { [weak c] tabBar in c?.attach(to: tabBar) }
            if let tabBar = finder.currentTabBar() { c.attach(to: tabBar) }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(accountManager: accountManager, onSwitch: onSwitch,
                    onAddAccount: onAddAccount, onManageAccounts: onManageAccounts)
    }
}

// MARK: - Coordinator

extension TabBarContextMenuAttacher {

    final class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var accountManager: AccountManager
        var onSwitch: (String) -> Void
        var onAddAccount: () -> Void
        var onManageAccounts: () -> Void

        private weak var attachedTabBar: UITabBar?
        private var interaction: UIContextMenuInteraction?
        /// A tiny invisible view used as the context menu preview target.
        /// Prevents UIKit from "lifting" the actual tab bar content.
        private var previewAnchor: UIView?

        init(accountManager: AccountManager,
             onSwitch: @escaping (String) -> Void,
             onAddAccount: @escaping () -> Void,
             onManageAccounts: @escaping () -> Void) {
            self.accountManager = accountManager
            self.onSwitch = onSwitch
            self.onAddAccount = onAddAccount
            self.onManageAccounts = onManageAccounts
        }

        func attach(to tabBar: UITabBar) {
            if let current = attachedTabBar,
               current === tabBar, current.window != nil, interaction != nil { return }
            cleanup()

            let ctx = UIContextMenuInteraction(delegate: self)
            tabBar.addInteraction(ctx)
            interaction = ctx
            attachedTabBar = tabBar

            // Tiny invisible anchor positioned at the Me tab center.
            // UIKit "lifts" this instead of the real tab bar content.
            let anchor = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            anchor.backgroundColor = .clear
            anchor.isUserInteractionEnabled = false
            tabBar.addSubview(anchor)
            previewAnchor = anchor
        }

        private func cleanup() {
            if let old = interaction { attachedTabBar?.removeInteraction(old) }
            previewAnchor?.removeFromSuperview()
            previewAnchor = nil
            interaction = nil
            attachedTabBar = nil
        }

        // MARK: - Me Tab Geometry

        private func meTabFrame(in tabBar: UITabBar) -> CGRect {
            let count = max(tabBar.items?.count ?? 4, 1)
            let meIndex = min(3, count - 1)
            let w = tabBar.bounds.width / CGFloat(count)
            return CGRect(x: CGFloat(meIndex) * w, y: 0,
                          width: w, height: tabBar.bounds.height)
        }

        // MARK: - UIContextMenuInteractionDelegate

        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            guard let tabBar = attachedTabBar else { return nil }

            // Only respond if the touch is within the Me tab area
            let frame = meTabFrame(in: tabBar)
            guard frame.insetBy(dx: -8, dy: -8).contains(location) else { return nil }

            return UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: nil,
                actionProvider: { [weak self] _ in self?.buildMenu() }
            )
        }

        /// Return an invisible 1×1 anchor so UIKit doesn't lift the tab bar content.
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
        ) -> UITargetedPreview? {
            guard let anchor = previewAnchor, let tabBar = attachedTabBar else { return nil }
            let frame = meTabFrame(in: tabBar)
            anchor.center = CGPoint(x: frame.midX, y: 4)
            let params = UIPreviewParameters()
            params.backgroundColor = .clear
            return UITargetedPreview(view: anchor, parameters: params)
        }

        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
        ) -> UITargetedPreview? {
            guard let anchor = previewAnchor, let tabBar = attachedTabBar else { return nil }
            let frame = meTabFrame(in: tabBar)
            anchor.center = CGPoint(x: frame.midX, y: 4)
            let params = UIPreviewParameters()
            params.backgroundColor = .clear
            return UITargetedPreview(view: anchor, parameters: params)
        }

        // MARK: - Menu Builder

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
                accountActions.append(
                    UIAction(title: current.username, image: avatar, state: .on) { _ in }
                )
            }

            let others = accountManager.accounts.filter { $0.username != accountManager.activeUsername }
            for account in others {
                let avatar = cachedAvatar(for: account.avatar)
                accountActions.append(
                    UIAction(title: account.username, image: avatar) { [weak self] _ in
                        DispatchQueue.main.async { self?.onSwitch(account.username) }
                    }
                )
            }

            var mgmtActions: [UIAction] = []
            mgmtActions.append(UIAction(
                title: "添加账号", image: UIImage(systemName: "plus.circle")
            ) { [weak self] _ in
                DispatchQueue.main.async { self?.onAddAccount() }
            })

            if !others.isEmpty {
                mgmtActions.append(UIAction(
                    title: "账号管理", image: UIImage(systemName: "person.2")
                ) { [weak self] _ in
                    DispatchQueue.main.async { self?.onManageAccounts() }
                })
            }

            return UIMenu(title: "", children: [
                UIMenu(title: "", options: .displayInline, children: accountActions),
                UIMenu(title: "", options: .displayInline, children: mgmtActions)
            ])
        }

        // MARK: - Avatar Cache

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
               let img = UIImage(data: data) {
                return circularImage(img, size: 24)
            }
            return placeholder
        }

        private func circularImage(_ image: UIImage, size: CGFloat) -> UIImage {
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            return UIGraphicsImageRenderer(bounds: rect).image { _ in
                UIBezierPath(ovalIn: rect).addClip()
                image.draw(in: rect)
            }
        }
    }
}
#endif
