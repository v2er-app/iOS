//
//  RootView.swift
//  V2er
//
//  Shared root host view (cross-platform).
//  iOS-specific RootView/RootHostingController/HostingWindowFinder
//  are in V2er-iOS/RootView_iOS.swift.
//

import SwiftUI

struct RootHostView: View {
    @ObservedObject private var store = Store.shared
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

    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

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
                .toast(isPresented: toast.isPresented, version: toast.version.raw) {
                    DefaultToastView(title: toast.title.raw, icon: toast.icon.raw)
                }
                .sheet(isPresented: loginState.showLoginView) {
                    NavigationStack {
                        LoginPage()
                            .navigationDestination(for: AppRoute.self) { $0.destination() }
                    }
                    .environmentObject(store)
                    .interactiveDismissDisabled()
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
        .environmentObject(store)
        .tint(Color("TintColor"))
        .preferredColorScheme(store.appState.settingState.appearance.colorScheme)
        .onAppear {
            if isUITesting, let topicId = getTestTopicId() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testTopicId = topicId
                }
            }
        }
    }
}
