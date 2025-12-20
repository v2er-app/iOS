//
//  SplashView.swift
//  V2er
//
//  Created by Claude on 2024/12/1.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.colorScheme) private var colorScheme

    @State private var showSlogan = false

    private let slogan = "Way to explore"

    // Logo color adapts to color scheme (matches Android)
    private var logoColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.067, green: 0.071, blue: 0.078)
    }

    var body: some View {
        ZStack {
            // Background color - matches Android implementation
            Color("SplashBackground")
                .ignoresSafeArea()

            // Logo - vector PDF with template rendering (fixed position)
            Image("SplashLogo")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundColor(logoColor)

            // Slogan with typewriter effect (fixed position below logo)
            if showSlogan {
                TypewriterView(text: slogan, typingDelay: .milliseconds(35))
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(logoColor.opacity(0.85))
                    .offset(y: 74)
            }
        }
        .onAppear {
            // Show slogan after a short delay
            runInMain(delay: 300) {
                showSlogan = true
            }

            // Hide splash after animation completes
            runInMain(delay: 1200) {
                store.dispatch(LaunchFinishedAction(), animation: .easeOut(duration: 0.3))

                // Trigger auto-checkin if enabled and not checked in today
                if store.appState.settingState.shouldAutoCheckinToday {
                    runInMain(delay: 500) {
                        dispatch(SettingActions.StartAutoCheckinAction())
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(Store.shared)
}
