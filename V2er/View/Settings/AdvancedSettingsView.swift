//
//  AdvancedSettingsView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher

struct AdvancedSettingsView: View {
    @ObservedObject private var store = Store.shared
    @State private var cacheSizeMB: Double = 0
    @State private var imgurClientId: String = ""
    @State private var showingImgurHelp = false
    @State private var v2exAccessToken: String = ""
    @State private var showingTokenHelp = false

    private var showDataSourceIndicator: Bool {
        store.appState.settingState.showDataSourceIndicator
    }

    private var v2exTokenEnabled: Bool {
        store.appState.settingState.v2exTokenEnabled
    }

    private var hasToken: Bool {
        !v2exAccessToken.isEmpty
    }

    var body: some View {
        List {
            // MARK: - Cache
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

            // MARK: - Data Source Indicator
            Section {
                Toggle("数据来源指示器", isOn: Binding(
                    get: { showDataSourceIndicator },
                    set: { newValue in
                        dispatch(SettingActions.ToggleDataSourceIndicatorAction(enabled: newValue))
                    }
                ))
            } footer: {
                Text("开启后，已迁移至 API v2 的页面会显示当前数据来源标识")
            }

            // MARK: - V2EX Access Token
            Section {
                if hasToken {
                    Toggle("启用", isOn: Binding(
                        get: { v2exTokenEnabled },
                        set: { newValue in
                            dispatch(SettingActions.ToggleV2exTokenEnabledAction(enabled: newValue))
                        }
                    ))
                }

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
                Text("V2EX Access Token")
            } footer: {
                Text("用于通过 V2EX 官方 API 加载内容。请在 v2ex.com/settings/tokens 创建，不需要勾选任何额外权限。设置后可通过开关临时停用而无需删除。")
            }

            // MARK: - Imgur Client ID
            Section {
                HStack {
                    TextField("留空则使用内置公共 ID", text: $imgurClientId)
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
                Text("用于图片上传。可在 api.imgur.com 注册获取自己的 Client ID，留空则使用内置公共 ID。")
            }
        }
        .navigationTitle("高级设置")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .onAppear {
            imgurClientId = SettingState.getImgurClientId() ?? ""
            v2exAccessToken = SettingState.getRawV2exAccessToken() ?? ""
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

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AdvancedSettingsView()
                .environmentObject(Store.shared)
        }
    }
}
