//
//  RootView_iOS.swift
//  V2er
//
//  iOS-specific root view infrastructure.
//  Manages UIHostingController, status bar style, and UIWindow references.
//

import SwiftUI
import UIKit

// MARK: - RootView (UIWindow bridge)

struct RootView<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        EmptyView()
            .withHostingWindow { window in
                V2erApp.window = window
                V2erApp.rootViewController = RootHostingController(rootView: content)
                window?.rootViewController = V2erApp.rootViewController
            }
    }
}

// MARK: - RootHostingController

class RootHostingController<Content: View>: UIHostingController<Content> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return V2erApp.statusBarState
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedMode = UserDefaults.standard.string(forKey: "appearanceMode") {
            applyAppearanceFromString(savedMode)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppearanceChange),
            name: NSNotification.Name("AppearanceDidChange"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func handleAppBecameActive() {
        checkAutoCheckin()
    }

    private func checkAutoCheckin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let store = Store.shared
            let settings = store.appState.settingState

            guard AccountState.hasSignIn() else { return }
            guard settings.shouldAutoCheckinToday else { return }
            guard !settings.isCheckingIn else { return }

            dispatch(SettingActions.StartAutoCheckinAction())
        }
    }

    @objc private func handleAppearanceChange(_ notification: Notification) {
        if let appearance = notification.object as? AppearanceMode {
            applyAppearanceFromString(appearance.rawValue)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            V2erApp.changeStatusBarStyle(V2erApp.defaultStatusBarStyle())
        }
    }

    func applyAppearanceFromString(_ modeString: String) {
        let style: UIUserInterfaceStyle
        switch modeString {
        case "light":
            style = .light
        case "dark":
            style = .dark
        default:
            style = .unspecified
        }
        overrideUserInterfaceStyle = style

        view.setNeedsDisplay()
        view.setNeedsLayout()

        DispatchQueue.main.async {
            V2erApp.changeStatusBarStyle(V2erApp.defaultStatusBarStyle())
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Status Bar Style Extension

extension View {
    func statusBarStyle(_ style: UIStatusBarStyle) -> some View {
        return self.onAppear {
            V2erApp.changeStatusBarStyle(style)
        }
        .onDisappear {
            V2erApp.changeStatusBarStyle(V2erApp.defaultStatusBarStyle())
        }
        .onChange(of: style) { newState in
            V2erApp.changeStatusBarStyle(newState)
        }
    }
}

// MARK: - HostingWindowFinder

extension View {
    func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
