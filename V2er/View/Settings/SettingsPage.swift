//
//  SettingsPage.swift
//  SettingsPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
#if os(iOS)
import SafariServices
#endif

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
    @State private var selectedSubSetting: AppRoute? = nil

    // Get version and build number from Bundle
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    var body: some View {
        GeometryReader { geo in
            let isSplit = geo.size.width > 500
            if isSplit {
                splitLayout(totalWidth: geo.size.width)
            } else {
                settingsListContent(isSplitMode: false)
            }
        }
        .sheet(item: $safariURL) { item in
            #if os(iOS)
            SafariView(url: item.url)
            #else
            InAppBrowserView(url: item.url)
            #endif
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

    // MARK: - Split Layout (iPad)

    private func splitLayout(totalWidth: CGFloat) -> some View {
        let leftWidth = min(max(totalWidth * 0.38, 280), 380)
        return HStack(spacing: 0) {
            NavigationStack {
                settingsListContent(isSplitMode: true)
            }
            .frame(width: leftWidth)

            Divider()

            NavigationStack {
                if let route = selectedSubSetting {
                    route.destination()
                        .navigationDestination(for: AppRoute.self) { $0.destination() }
                } else {
                    settingsPlaceholder
                }
            }
            .id(selectedSubSetting)
        }
    }

    // MARK: - Placeholder

    private var settingsPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "gearshape")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("选择一个设置项")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Settings List Content

    private func settingsListContent(isSplitMode: Bool) -> some View {
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
                            .foregroundStyle(Color.tertiaryText)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)
            }

            // MARK: - Settings Section
            Section("设置") {
                settingsNavRow(route: .appearanceSettings, isSplitMode: isSplitMode) {
                    Label("外观设置", systemImage: "paintbrush")
                }

                settingsNavRow(route: .otherSettings, isSplitMode: isSplitMode) {
                    Label("通用设置", systemImage: "gearshape")
                }
            }

            // MARK: - Help Section
            Section("帮助") {
                Button {
                    openURL("https://www.v2ex.com/help")
                } label: {
                    HStack {
                        Label("V2EX 帮助", systemImage: "book")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.tertiaryText)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)

                Button {
                    openURL("https://github.com/v2er-app")
                } label: {
                    HStack {
                        Label("源码开放", systemImage: "chevron.left.forwardslash.chevron.right")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.tertiaryText)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .foregroundStyle(.primary)
            }

            // MARK: - About Section
            Section("关于") {
                settingsNavRow(route: .credits, isSplitMode: isSplitMode) {
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
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.tertiaryText)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    // MARK: - Settings Navigation Row

    @ViewBuilder
    private func settingsNavRow<Label: View>(route: AppRoute, isSplitMode: Bool, @ViewBuilder label: () -> Label) -> some View {
        if isSplitMode {
            Button {
                selectedSubSetting = route
            } label: {
                HStack {
                    label()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.tertiaryText)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .foregroundStyle(.primary)
            .listRowBackground(selectedSubSetting == route ? Color.accentColor.opacity(0.12) : nil)
        } else {
            NavigationLink(value: route) {
                label()
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
