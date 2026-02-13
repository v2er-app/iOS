//
//  OtherSettingsView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher

struct OtherSettingsView: View {
    @ObservedObject private var store = Store.shared
    @State private var cacheSizeMB: Double = 0
    @State private var imgurClientId: String = ""
    @State private var showingImgurHelp = false
    @State private var v2exAccessToken: String = ""
    @State private var showingTokenHelp = false

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

            // MARK: - Cache Section
            Section {
                Button {
                    ImageCache.default.clearDiskCache {
                        cacheSizeMB = 0
                        Toast.show("缓存清理完成")
                    }
                } label: {
                    HStack {
                        Text("清除缓存")
                        Spacer()
                        Text(String(format: "%.2f MB", cacheSizeMB))
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
            } header: {
                Text("缓存")
            } footer: {
                Text("清除图片缓存可释放存储空间")
            }

            // MARK: - V2EX API Section
            Section {
                HStack {
                    SecureField("输入 Personal Access Token", text: $v2exAccessToken)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                        .onChange(of: v2exAccessToken) { _, newValue in
                            SettingState.saveV2exAccessToken(newValue)
                        }

                    Button {
                        showingTokenHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("V2EX API")
            } footer: {
                Text("配置后将通过官方 API 加载帖子详情，速度更快更稳定")
            }

            // MARK: - Imgur Section
            Section {
                HStack {
                    TextField("使用内置 Client ID", text: $imgurClientId)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                        .onChange(of: imgurClientId) { _, newValue in
                            SettingState.saveImgurClientId(newValue)
                        }

                    Button {
                        showingImgurHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Imgur Client ID")
            } footer: {
                Text("用于图片上传，留空则使用内置公共 ID")
            }
        }
        .navigationTitle("通用设置")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .onAppear {
            imgurClientId = SettingState.getImgurClientId() ?? ""
            v2exAccessToken = SettingState.getV2exAccessToken() ?? ""
        }
        .task {
            ImageCache.default.calculateDiskStorageSize { result in
                switch result {
                case .success(let size):
                    cacheSizeMB = Double(size) / 1024 / 1024
                case .failure(let error):
                    print("Failed to calculate cache size: \(error)")
                }
            }
        }
        .alert("Imgur Client ID", isPresented: $showingImgurHelp) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("Imgur Client ID 用于上传图片。你可以在 https://api.imgur.com/oauth2/addclient 注册获取自己的 Client ID。如不填写，将使用内置的公共 ID。")
        }
        .alert("V2EX Access Token", isPresented: $showingTokenHelp) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("Personal Access Token 用于通过 V2EX 官方 API 加载内容。请在 v2ex.com/settings/tokens 创建一个 Token，不需要勾选任何额外权限。")
        }
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
