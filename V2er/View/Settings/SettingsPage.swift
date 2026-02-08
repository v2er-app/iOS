//
//  SettingsPage.swift
//  SettingsPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import SafariServices

// Wrapper to make URL Identifiable for sheet presentation
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsPage: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAccountAlert = false
    @State private var showingLogoutConfirmation = false
    @State private var safariURL: IdentifiableURL?

    // Get version and build number from Bundle
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    var body: some View {
        List {
            // MARK: - Feedback Section
            Section {
                Button {
                    openURL("https://v2er.app/help")
                } label: {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("问题反馈")
                                Text("https://v2er.app/help")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "questionmark.circle")
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)
            }

            // MARK: - Settings Section
            Section("设置") {
                NavigationLink(value: AppRoute.appearanceSettings) {
                    Label("外观设置", systemImage: "paintbrush")
                }

                NavigationLink(value: AppRoute.otherSettings) {
                    Label("通用设置", systemImage: "gearshape")
                }
            }

            // MARK: - Help Section
            Section("帮助") {
                Button {
                    openURL("https://www.v2ex.com/help")
                } label: {
                    Label("V2EX 帮助", systemImage: "book")
                }
                .foregroundStyle(.primary)

                Button {
                    openURL("https://github.com/v2er-app")
                } label: {
                    Label("源码开放", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                .foregroundStyle(.primary)
            }

            // MARK: - About Section
            Section("关于") {
                NavigationLink(value: AppRoute.credits) {
                    Label("致谢", systemImage: "heart")
                }

                Button {
                    openURL("https://v2er.app")
                } label: {
                    HStack {
                        Label("关于 V2er", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
            }

            // MARK: - Account Section
            Section {
                Button {
                    showingDeleteAccountAlert = true
                } label: {
                    Label("账号注销", systemImage: "person.crop.circle.badge.minus")
                }
                .foregroundStyle(.primary)

                Button(role: .destructive) {
                    showingLogoutConfirmation = true
                } label: {
                    Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $safariURL) { item in
            SafariView(url: item.url)
        }
        .alert("账号注销", isPresented: $showingDeleteAccountAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("V2er 作为 V2EX 的第三方客户端无法提供账号注销功能，若你想注销账号可访问 V2EX 官方网站: https://www.v2ex.com/help, 或联系 V2EX 团队: support@v2ex.com")
        }
        .confirmationDialog(
            "登出吗?",
            isPresented: $showingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("确定", role: .destructive) {
                AccountState.deleteAccount()
                Toast.show("已登出")
                dismiss()
            }
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            safariURL = IdentifiableURL(url: url)
        }
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsPage()
        }
    }
}
