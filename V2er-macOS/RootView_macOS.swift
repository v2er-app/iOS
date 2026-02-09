//
//  RootView_macOS.swift
//  V2er
//
//  macOS-specific root view.
//  On macOS there is no UIHostingController bridge needed;
//  we go straight into the shared RootHostView / MainPage hierarchy.
//  The existing iPadLayout path in MainPage naturally provides
//  NavigationSplitView which works well on macOS.
//

import SwiftUI
import AppKit

// MARK: - Auto-checkin on app activation (macOS equivalent of iOS didBecomeActive)

struct MacOSLifecycleModifier: ViewModifier {
    @ObservedObject private var store = Store.shared

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                checkAutoCheckin()
            }
    }

    private func checkAutoCheckin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let settings = store.appState.settingState

            guard AccountState.hasSignIn() else { return }
            guard settings.shouldAutoCheckinToday else { return }
            guard !settings.isCheckingIn else { return }

            dispatch(SettingActions.StartAutoCheckinAction())
        }
    }
}

extension View {
    func macOSLifecycle() -> some View {
        modifier(MacOSLifecycleModifier())
    }
}
