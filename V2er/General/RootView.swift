//
//  StatusBarController.swift
//  Insert this into your project.
//  Created by Xavier Donnellon
//

import SwiftUI

struct RootView<Content: View> : View {
    var content: Content

    init(@ViewBuilder content: ()-> Content) {
        self.content = content()
    }

    var body:some View {
        EmptyView()
            .withHostingWindow { window in
                V2erApp.window = window
                V2erApp.rootViewController = RootHostingController(rootView: content)
                window?.rootViewController = V2erApp.rootViewController
            }
    }
}

class RootHostingController<Content: View>: UIHostingController<Content> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return V2erApp.statusBarState
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Apply the saved appearance mode
        if let savedMode = UserDefaults.standard.string(forKey: "appearanceMode") {
            applyAppearanceFromString(savedMode)
        }

        // Listen for appearance changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppearanceChange),
            name: NSNotification.Name("AppearanceDidChange"),
            object: nil
        )

        // Listen for app becoming active to trigger auto-checkin
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
        let store = Store.shared
        let settings = store.appState.settingState

        // Only attempt checkin if user is logged in
        guard AccountState.hasSignIn() else { return }
        guard settings.shouldAutoCheckinToday else { return }
        // Prevent concurrent check-in attempts
        guard !settings.isCheckingIn else { return }

        // Small delay to avoid interfering with app state restoration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dispatch(SettingActions.StartAutoCheckinAction())
        }
    }

    @objc private func handleAppearanceChange(_ notification: Notification) {
        if let appearance = notification.object as? AppearanceMode {
            applyAppearanceFromString(appearance.rawValue)
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

        // Force the view to redraw
        view.setNeedsDisplay()
        view.setNeedsLayout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension View {
    func statusBarStyle(_ style: UIStatusBarStyle, original: UIStatusBarStyle = .darkContent) -> some View {
        return self.onAppear {
            V2erApp.changeStatusBarStyle(style)
        }
        .onDisappear {
            V2erApp.changeStatusBarStyle(original)
        }
        .onChange(of: style) { newState in
            V2erApp.changeStatusBarStyle(newState)
        }
    }
}


struct RootHostView: View {
    @EnvironmentObject private var store: Store
    @State private var testTopicId: String? = nil

    var toast: Binding<Toast> {
        $store.appState.globalState.toast
    }

    var loginState: Binding<LoginState> {
        $store.appState.loginState
    }

    var launchFinished: Bool {
        store.appState.globalState.launchFinished
    }

    /// Check for UI test launch arguments
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

    /// Get test topic ID from launch arguments
    private func getTestTopicId() -> String? {
        let args = ProcessInfo.processInfo.arguments
        if let topicArgIndex = args.firstIndex(of: "--test-topic"),
           topicArgIndex + 1 < args.count {
            return args[topicArgIndex + 1]
        }
        return nil
    }

    var body: some View {
        ZStack {
            MainPage()
                .buttonStyle(.plain)
                .toast(isPresented: toast.isPresented) {
                    DefaultToastView(title: toast.title.raw, icon: toast.icon.raw)
                }
                .sheet(isPresented: loginState.showLoginView) {
                    LoginPage()
                }
                .overlay {
                    if loginState.raw.showTwoStepDialog {
                        TwoStepLoginPage()
                    }
                }

            if !launchFinished {
                SplashView()
                    .transition(.opacity)
            }

            // UI Test navigation overlay
            if let topicId = testTopicId {
                NavigationStack {
                    FeedDetailPage(id: topicId)
                }
                .accessibilityIdentifier("TestTopicDetailView")
            }
        }
        .onAppear {
            // Check for test topic navigation on appear
            if isUITesting, let topicId = getTestTopicId() {
                // Small delay to ensure app is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testTopicId = topicId
                }
            }
        }
    }
}
