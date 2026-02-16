//
//  OtherSettingsView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct OtherSettingsView: View {
    @ObservedObject private var store = Store.shared

    private var autoCheckin: Bool {
        store.appState.settingState.autoCheckin
    }

    private var isCheckingIn: Bool {
        store.appState.settingState.isCheckingIn
    }

    private var isLoggedIn: Bool {
        AccountState.hasSignIn()
    }

    private var useBuiltinBrowser: Bool {
        store.appState.settingState.useBuiltinBrowser
    }

    var body: some View {
        List {
            // MARK: - Checkin Section
            Section {
                // Manual Checkin Button
                Button {
                    if isLoggedIn && !isCheckingIn {
                        dispatch(SettingActions.StartAutoCheckinAction())
                    } else if !isLoggedIn {
                        Toast.show("请先登录")
                    }
                } label: {
                    HStack {
                        Text("手动签到")
                        Spacer()
                        if isCheckingIn {
                            ProgressView()
                        } else {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(isLoggedIn ? Color.accentColor : Color.secondary)
                        }
                    }
                }
                .foregroundStyle(.primary)
                .disabled(isCheckingIn)

                // Auto Checkin Toggle
                Toggle("自动签到", isOn: Binding(
                    get: { autoCheckin },
                    set: { newValue in
                        dispatch(SettingActions.ToggleAutoCheckinAction(enabled: newValue))
                    }
                ))
            } header: {
                Text("签到")
            } footer: {
                Text("开启后每次打开 App 时会自动尝试签到")
            }

            // MARK: - Browser Section
            Section {
                Toggle("内置浏览器", isOn: Binding(
                    get: { useBuiltinBrowser },
                    set: { newValue in
                        dispatch(SettingActions.ToggleBuiltinBrowserAction(enabled: newValue))
                    }
                ))
            } footer: {
                Text("开启后站外链接将在内置浏览器中打开")
            }

        }
        .navigationTitle("通用设置")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

struct OtherSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OtherSettingsView()
                .environmentObject(Store.shared)
        }
    }
}
