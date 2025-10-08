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

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            if isShowing {
                // Background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }
                    .transition(.opacity)

                // Menu content
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Tab.allTabs, id: \.self) { tab in
                                TabFilterButton(
                                    tab: tab,
                                    isSelected: tab == selectedTab,
                                    needsLogin: tab.needsLogin() && !AccountState.hasSignIn()
                                ) {
                                    if tab.needsLogin() && !AccountState.hasSignIn() {
                                        Toast.show("登录后才能查看「\(tab.displayName())」下的内容")
                                    } else {
                                        onTabSelected(tab)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.itemBg)
                    .cornerRadius(12)
                    .padding()
                    .frame(maxHeight: 400)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isShowing)
    }
}

struct TabFilterButton: View {
    let tab: Tab
    let isSelected: Bool
    let needsLogin: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tab.displayName())
                .font(.system(size: 14))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isSelected ? 1.5 : 0)
                )
        }
        .opacity(needsLogin ? 0.5 : 1.0)
    }

    private var textColor: Color {
        if isSelected {
            return Color.dynamic(light: .hex(0x2E7EF3), dark: .hex(0x5E9EFF))
        } else {
            return Color.primaryText
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.dynamic(light: .hex(0xE8F2FF), dark: .hex(0x1A3A52))
        } else {
            return Color.dynamic(light: .hex(0xF5F5F5), dark: .hex(0x2C2C2E))
        }
    }

    private var borderColor: Color {
        return Color.dynamic(light: .hex(0x2E7EF3), dark: .hex(0x5E9EFF))
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
