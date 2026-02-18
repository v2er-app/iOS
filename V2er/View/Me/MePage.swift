//
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//  MePage.swift
//  V2er
//

import SwiftUI

struct MePage: BaseHomePageView {
    @ObservedObject private var store = Store.shared
    @Environment(\.iPadDetailRoute) private var iPadDetailRoute
    @ObservedObject private var otherAppsManager = OtherAppsManager.shared
    @StateObject private var accountManager = AccountManager.shared
    @State private var showAccountSwitcher = false

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
    @State private var carouselIndex = 0
    @State private var navigateToUserDetail: AppRoute?
    @State private var navigateToAllApps: AppRoute?

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
                SplitNavigationLink(route: .createTopic) {
                    Label("发帖", systemImage: "pencil")
                }
            }

            // MARK: - My Content Section
            Section("我的") {
                SplitNavigationLink(route: .userFeed(userId: AccountState.userName)) {
                    Label("主题", systemImage: "paperplane")
                }

                SplitNavigationLink(route: .myFavorites) {
                    Label("收藏", systemImage: "bookmark")
                }

                SplitNavigationLink(route: .myFollow) {
                    Label("关注", systemImage: "heart")
                }

                SplitNavigationLink(route: .myRecent) {
                    Label("最近浏览", systemImage: "clock")
                }

                SplitNavigationLink(route: .myUploads) {
                    Label("我的图片", systemImage: "photo.on.rectangle")
                }
            }

            // MARK: - Other Apps Section
            Section {
                OtherAppCarouselView(apps: otherApps, currentIndex: $carouselIndex, isVisible: isSelected)
                    .listRowInsets(EdgeInsets())
            } header: {
                HStack {
                    Spacer()
                    Button {
                        navigateToAllApps = .allOtherApps
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Text("查看全部")
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
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
            // Initialize with fixed order, random start index on first appear
            if otherApps.isEmpty {
                otherApps = OtherAppsManager.otherApps
                if !otherApps.isEmpty {
                    carouselIndex = Int.random(in: 0..<otherApps.count)
                }
            }
        }
        .navigationTitle("我")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                SplitNavigationLink(route: .settings) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    // MARK: - User Banner View
    @ViewBuilder
    private var userBannerView: some View {
        VStack(spacing: Spacing.lg) {
            // Profile row
            HStack(spacing: Spacing.lg) {
                Button {
                    showAccountSwitcher = true
                } label: {
                    AvatarView(url: AccountState.avatarUrl, size: 64)
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                        .overlay(alignment: .topTrailing) {
                            if accountManager.accounts.count > 1 {
                                Text("\(accountManager.accounts.count)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 18, minHeight: 18)
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        navigateToProfile()
                    } label: {
                        Label("查看主页", systemImage: "person.crop.circle")
                    }
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Button {
                        navigateToProfile()
                    } label: {
                        Text(AccountState.userName)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.primaryText)
                    }
                    .buttonStyle(.plain)

                    if let balance = AccountState.balance, balance.isValid() {
                        BalanceView(balance: balance, size: 13)
                    }
                }

                Spacer()

                // Checkin Button
                Button {
                    dispatch(SettingActions.StartAutoCheckinAction())
                } label: {
                    HStack(spacing: Spacing.xs) {
                        if isCheckingIn {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(hasCheckedInToday ? Color.secondary : Color.accentColor)
                        } else {
                            Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.subheadline)
                        }
                        Text(hasCheckedInToday ? "已签到" : "签到")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(hasCheckedInToday ? .secondary : .accentColor)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(hasCheckedInToday ? Color.secondary.opacity(0.1) : Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
                }
                .disabled(isCheckingIn)
                .accessibilityLabel(hasCheckedInToday ? "已签到" : "签到")
                .accessibilityHint(hasCheckedInToday ? "今日已完成签到" : "点击完成每日签到")
            }

            // Streak info bar
            if checkinDays > 0 {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    Text("已连续签到 \(checkinDays) 天")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color(.systemGray5).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            }
        }
        .padding(.vertical, Spacing.sm)
        .navigationDestination(item: $navigateToUserDetail) { route in
            route.destination()
        }
        .navigationDestination(item: $navigateToAllApps) { route in
            route.destination()
        }
        .sheet(isPresented: $showAccountSwitcher) {
            AccountSwitcherView()
        }
    }

    private func navigateToProfile() {
        let route = AppRoute.userDetail(userId: AccountState.userName)
        if let detailRoute = iPadDetailRoute {
            detailRoute.wrappedValue = route
        } else {
            navigateToUserDetail = route
        }
    }

    // MARK: - Login Overlay View
    @ViewBuilder
    private var loginOverlayView: some View {
        VStack(spacing: Spacing.lg) {
            Text("登录查看更多")
                .foregroundColor(.primary)
                .font(.title2)
            Button {
                dispatch(LoginActions.ShowLoginPageAction())
            } label: {
                Text("登录")
                    .font(.headline)
                    .foregroundColor(Color(.systemBackground))
                    .padding()
                    .padding(.horizontal, 50)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Other App Carousel View

private struct OtherAppCarouselView: View {
    let apps: [OtherApp]
    @Binding var currentIndex: Int
    let isVisible: Bool
    @State private var scrolledID: String?
    // Incrementing this restarts the auto-rotation timer
    @State private var timerEpoch = 0
    // Tracks visibility changes for the delayed advance task
    @State private var visibilityEpoch = 0
    private let autoRotateInterval: UInt64 = 10_000_000_000 // 10s

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(apps) { app in
                        OtherAppItemView(app: app)
                            .frame(maxHeight: .infinity)
                            .padding(.horizontal, Spacing.lg)
                            .containerRelativeFrame(.horizontal)
                            .id(app.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .onChange(of: scrolledID) { _, newID in
                if let newID, let idx = apps.firstIndex(where: { $0.id == newID }) {
                    if currentIndex != idx {
                        currentIndex = idx
                        // User swiped manually — restart timer
                        timerEpoch += 1
                    }
                }
            }
            .onChange(of: currentIndex) { _, newIndex in
                guard apps.indices.contains(newIndex) else { return }
                let targetID = apps[newIndex].id
                if scrolledID != targetID {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        scrolledID = targetID
                    }
                }
            }
            .onAppear {
                guard apps.indices.contains(currentIndex) else { return }
                scrolledID = apps[currentIndex].id
            }

            // Page dots
            HStack(spacing: 6) {
                ForEach(apps.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
            }
            .padding(.bottom, Spacing.xs)
        }
        // Advance after a short delay when tab becomes visible, then restart timer
        .onChange(of: isVisible) { _, visible in
            if visible && apps.count > 1 {
                visibilityEpoch += 1
            }
        }
        .task(id: visibilityEpoch) {
            guard visibilityEpoch > 0, apps.count > 1 else { return }
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                currentIndex = (currentIndex + 1) % apps.count
            }
            timerEpoch += 1
        }
        // Auto-rotation: restarts whenever timerEpoch changes
        .task(id: timerEpoch) {
            guard apps.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: autoRotateInterval)
                guard !Task.isCancelled else { break }
                withAnimation(.easeInOut(duration: 0.35)) {
                    currentIndex = (currentIndex + 1) % apps.count
                }
            }
        }
    }
}

// MARK: - Other App Item View

struct OtherAppItemView: View {
    let app: OtherApp
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url = app.appStoreUrl {
                openURL(url)
            }
        } label: {
            HStack(spacing: Spacing.md) {
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
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            .contentShape(Rectangle())
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - All Other Apps Page

struct AllOtherAppsPage: View {
    private let apps = OtherAppsManager.otherApps

    var body: some View {
        List(apps) { app in
            OtherAppItemView(app: app)
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .navigationTitle("更多 App")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct AccountPage_Previews: PreviewProvider {
    static var selected = TabId.me

    static var previews: some View {
        MePage(selecedTab: selected)
            .environmentObject(Store.shared)
    }
}
