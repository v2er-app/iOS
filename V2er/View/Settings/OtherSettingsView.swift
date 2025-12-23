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
    @EnvironmentObject private var store: Store
    @State var sizeM: CGFloat = 0
    @State private var imgurClientId: String = ""
    @State private var showingImgurHelp = false

    private var autoCheckin: Bool {
        store.appState.settingState.autoCheckin
    }

    private var isCheckingIn: Bool {
        store.appState.settingState.isCheckingIn
    }

    private var isLoggedIn: Bool {
        AccountState.hasSignIn()
    }

    var body: some View {
        formView
            .navBar("通用设置")
            .onAppear {
                imgurClientId = SettingState.getImgurClientId() ?? ""
            }
            .task {
                ImageCache.default.calculateDiskStorageSize { result in
                    switch result {
                        case .success(let size):
                            sizeM = CGFloat(size) / 1024 / 1024
                            log("Disk cache size: \(sizeM)MB")
                        case .failure(let error):
                            print(error)
                    }
                }
            }
            .alert("Imgur Client ID", isPresented: $showingImgurHelp) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("Imgur Client ID 用于上传图片。你可以在 https://api.imgur.com/oauth2/addclient 注册获取自己的 Client ID。如不填写，将使用内置的公共 ID。")
            }
    }

    @ViewBuilder
    private var formView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Manual Checkin Button
                Button {
                    if isLoggedIn && !isCheckingIn {
                        dispatch(SettingActions.StartAutoCheckinAction())
                    } else if !isLoggedIn {
                        Toast.show("请先登录")
                    }
                } label: {
                    SectionView("手动签到", showDivider: true) {
                        HStack {
                            if isCheckingIn {
                                ProgressView()
                                    .padding(.trailing, 16)
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .font(.body.weight(.regular))
                                    .foregroundColor(isLoggedIn ? Color.tintColor : .secondaryText)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                }
                .disabled(isCheckingIn)

                // Auto Checkin Toggle
                SectionView("自动签到", showDivider: true) {
                    Toggle("", isOn: Binding(
                        get: { autoCheckin },
                        set: { newValue in
                            dispatch(SettingActions.ToggleAutoCheckinAction(enabled: newValue))
                        }
                    ))
                    .labelsHidden()
                    .padding(.trailing, 16)
                }

                Text("开启后每次打开App时会自动尝试签到")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 12)

                // Cache Clear
                Button {
                    ImageCache.default.clearDiskCache {
                        sizeM = 0
                        Toast.show("缓存清理完成")
                    }
                } label: {
                    SectionView("缓存", showDivider: false) {
                        HStack {
                            let size = String(format: "%.2f", sizeM)
                            Text("\(size)MB")
                                .font(.footnote)
                                .foregroundColor(Color.tintColor)
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.regular))
                                .foregroundColor(.secondaryText)
                                .padding(.trailing, 16)
                        }
                    }
                }

                // Imgur Client ID
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Imgur Client ID")
                            .foregroundColor(.primaryText)
                        Button {
                            showingImgurHelp = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondaryText)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    HStack {
                        TextField("使用内置 Client ID", text: $imgurClientId)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: imgurClientId) { _, newValue in
                                SettingState.saveImgurClientId(newValue)
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .background(Color.itemBg)
                .padding(.top, 8)

                Text("用于图片上传，留空则使用内置公共 ID")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
            }
        }
    }
}

struct OtherSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherSettingsView()
    }
}
