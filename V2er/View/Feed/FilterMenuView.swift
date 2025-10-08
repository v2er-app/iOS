//
//  FilterMenuView.swift
//  V2er
//
//  Created by Claude on 2025/10/08.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import SwiftUI

struct FilterMenuView: View {
    @EnvironmentObject private var store: Store
    let selectedTab: Tab
    let isShowing: Bool
    let onTabSelected: (Tab) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            if isShowing {
                // Background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Soft haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()

                        onDismiss()
                    }
                    .transition(.opacity)

                // Menu content - positioned below navbar
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        ScrollView {
                            VStack(spacing: 4) {
                                ForEach(Tab.allTabs, id: \.self) { tab in
                                    TabFilterMenuItem(
                                        tab: tab,
                                        isSelected: tab == selectedTab,
                                        needsLogin: tab.needsLogin() && !AccountState.hasSignIn()
                                    ) {
                                        // Soft haptic feedback
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()

                                        if tab.needsLogin() && !AccountState.hasSignIn() {
                                            Toast.show("登录后才能查看「\(tab.displayName())」下的内容")
                                        } else {
                                            onTabSelected(tab)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(width: 200)
                        .background(Color.itemBg)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
                        .frame(maxHeight: 450)
                        Spacer()
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))

                    Spacer()
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isShowing)
    }
}

struct TabFilterMenuItem: View {
    let tab: Tab
    let isSelected: Bool
    let needsLogin: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 24)

            Text(tab.displayName())
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(textColor)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .opacity(needsLogin ? 0.5 : (isPressed ? 0.7 : 1.0))
        .onTapGesture {
            action()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }

    private var iconName: String {
        switch tab {
        case .all: return "house.fill"
        case .tech: return "desktopcomputer"
        case .creative: return "lightbulb.fill"
        case .play: return "gamecontroller.fill"
        case .apple: return "apple.logo"
        case .jobs: return "briefcase.fill"
        case .deals: return "cart.fill"
        case .city: return "building.2.fill"
        case .qna: return "questionmark.circle.fill"
        case .hot: return "flame.fill"
        case .r2: return "arrow.clockwise"
        case .nodes: return "square.grid.3x3.fill"
        case .members: return "person.2.fill"
        }
    }

    private var textColor: Color {
        if isSelected {
            return Color.dynamic(light: .hex(0x2E7EF3), dark: .hex(0x5E9EFF))
        } else {
            return Color.primaryText
        }
    }

    private var iconColor: Color {
        if isSelected {
            return Color.dynamic(light: .hex(0x2E7EF3), dark: .hex(0x5E9EFF))
        } else {
            return Color.dynamic(light: .hex(0x666666), dark: .hex(0x999999))
        }
    }

    private var backgroundColor: Color {
        if isPressed {
            // Pressed state - slightly darker background
            return Color.dynamic(light: .hex(0xE0E0E0).opacity(0.5), dark: .hex(0x2A2A2A).opacity(0.5))
        } else if isSelected {
            return Color.dynamic(light: .hex(0xF0F7FF), dark: .hex(0x1A2533))
        } else {
            return Color.clear
        }
    }
}

#if DEBUG
struct FilterMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FilterMenuView(
            selectedTab: .all,
            isShowing: true,
            onTabSelected: { _ in },
            onDismiss: {}
        )
        .environmentObject(Store.shared)
    }
}
#endif
