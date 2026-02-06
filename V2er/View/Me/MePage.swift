//
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//  MePage.swift
//  V2er
//

import SwiftUI

struct MePage: BaseHomePageView {
    @EnvironmentObject private var store: Store
    @ObservedObject private var otherAppsManager = OtherAppsManager.shared

    var bindingState: Binding<MeState> {
        $store.appState.meState
    }
    var selecedTab: TabId
    var isSelected: Bool {
        let selected = selecedTab == .me
        return selected
    }

    private var isCheckingIn: Bool {
        store.appState.settingState.isCheckingIn
    }

    private var checkinDays: Int {
        store.appState.settingState.checkinDays
    }

    private var hasCheckedInToday: Bool {
        guard let lastDate = store.appState.settingState.lastCheckinDate else {
            return false
        }
        return Calendar.current.isDateInToday(lastDate)
    }

    @State private var otherApps: [OtherApp] = []

    var body: some View {
        List {
            // MARK: - User Banner Section
            Section {
                userBannerView
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            // MARK: - Content Section
            Section {
                NavigationLink {
                    CreateTopicPage()
                } label: {
                    Label("发帖", systemImage: "pencil")
                }
            }

            // MARK: - My Content Section
            Section("我的") {
                NavigationLink {
                    UserFeedPage(userId: AccountState.userName)
                } label: {
                    Label("主题", systemImage: "paperplane")
                }

                NavigationLink {
                    MyFavoritePage()
                } label: {
                    Label("收藏", systemImage: "bookmark")
                }

                NavigationLink {
                    MyFollowPage()
                } label: {
                    Label("关注", systemImage: "heart")
                }

                NavigationLink {
                    MyRecentPage()
                } label: {
                    Label("最近浏览", systemImage: "clock")
                }

                NavigationLink {
                    MyUploadsPage()
                } label: {
                    Label("我的图片", systemImage: "photo.on.rectangle")
                }
            }

            // MARK: - Other Apps Section
            Section {
                ForEach(otherApps, id: \.id) { app in
                    OtherAppItemView(app: app)
                }
            } footer: {
                Text("感谢你的支持")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if !AccountState.hasSignIn() {
                loginOverlayView
            }
        }
        .onAppear {
            if AccountState.hasSignIn() {
                dispatch(MeActions.FetchBalance.Start())
            }
            otherAppsManager.dismissBadge()
            // Initialize with shuffled apps on first appear
            if otherApps.isEmpty {
                otherApps = OtherAppsManager.otherApps.shuffled()
            }
        }
        .onChange(of: isSelected) { _, newValue in
            // Shuffle apps when tab becomes selected
            if newValue {
                otherApps = OtherAppsManager.otherApps.shuffled()
            }
        }
        .navigationTitle("我")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsPage()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    // MARK: - User Banner View
    @ViewBuilder
    private var userBannerView: some View {
        HStack(spacing: 10) {
            AvatarView(url: AccountState.avatarUrl, size: 60)
                .to {
                    UserDetailPage(userId: AccountState.userName)
                }
            VStack(alignment: .leading, spacing: 6) {
                Text(AccountState.userName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .to {
                        UserDetailPage(userId: AccountState.userName)
                    }
                if let balance = AccountState.balance, balance.isValid() {
                    BalanceView(balance: balance, size: 12)
                }
                if checkinDays > 0 {
                    Text("已连续签到 \(checkinDays) 天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            // Checkin Button
            Button {
                dispatch(SettingActions.StartAutoCheckinAction())
            } label: {
                HStack(spacing: 4) {
                    if isCheckingIn {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(hasCheckedInToday ? Color.secondary : Color.tintColor)
                    } else {
                        Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 16))
                    }
                    Text(hasCheckedInToday ? "已签到" : "签到")
                        .font(.subheadline)
                }
                .foregroundColor(hasCheckedInToday ? .secondary : .tintColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(hasCheckedInToday ? Color.secondary.opacity(0.12) : Color.tintColor.opacity(0.12))
                .clipShape(Capsule())
            }
            .disabled(isCheckingIn)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Login Overlay View
    @ViewBuilder
    private var loginOverlayView: some View {
        VStack(spacing: 16) {
            Text("登录查看更多")
                .foregroundColor(.primary)
                .font(.title2)
            Button {
                dispatch(LoginActions.ShowLoginPageAction())
            } label: {
                Text("登录")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 50)
                    .background(Color.tintColor)
                    .cornerRadius(15)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Other App Item View

private struct OtherAppItemView: View {
    let app: OtherApp

    var body: some View {
        Button {
            if let url = app.appStoreUrl {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                // App Icon
                Image(app.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                    )

                // App Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(app.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Download Button
                Text("获取")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.tintColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

struct AccountPage_Previews: PreviewProvider {
    static var selected = TabId.me

    static var previews: some View {
        MePage(selecedTab: selected)
            .environmentObject(Store.shared)
    }
}
