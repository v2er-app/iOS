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

    var toast: Binding<Toast> {
        $store.appState.globalState.toast
    }

    var loginState: Binding<LoginState> {
        $store.appState.loginState
    }

    var body: some View {
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

    }
}
