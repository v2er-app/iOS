//
//  iPadSidebarView.swift
//  V2er
//

import SwiftUI

struct iPadSidebarView: View {
    @Binding var selectedTab: TabId
    var unReadNums: Int
    var onReselect: (() -> Void)? = nil
    var onSwitchAccount: ((String) -> Void)? = nil
    var onAddAccount: (() -> Void)? = nil
    var onManageAccounts: (() -> Void)? = nil
    @ObservedObject private var accountManager = AccountManager.shared

    private var optionalSelection: Binding<TabId?> {
        Binding<TabId?>(
            get: { selectedTab },
            set: { newValue in
                guard let newValue else { return }
                if newValue == selectedTab {
                    onReselect?()
                } else {
                    selectedTab = newValue
                }
            }
        )
    }

    var body: some View {
        List(selection: optionalSelection) {
            Label("最新", systemImage: "newspaper")
                .tag(TabId.feed)

            Label("搜索", systemImage: "magnifyingglass")
                .tag(TabId.explore)

            Label {
                Text("通知")
            } icon: {
                Image(systemName: "bell")
                    .overlay(alignment: .topTrailing) {
                        if unReadNums > 0 {
                            Text("\(unReadNums)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.red, in: Capsule())
                                .offset(x: 8, y: -6)
                        }
                    }
            }
            .tag(TabId.message)

            Label("我", systemImage: "person")
                .tag(TabId.me)
                .contextMenu {
                    accountContextMenuItems
                }
        }
        .listStyle(.sidebar)
        .navigationTitle("V2er")
    }

    // MARK: - Account Context Menu

    @ViewBuilder
    private var accountContextMenuItems: some View {
        let isLoggedIn = AccountState.hasSignIn()

        if isLoggedIn {
            // Current account (checkmarked)
            if let current = accountManager.currentAccount {
                Button {
                    // Already active — no-op
                } label: {
                    Label(current.username, systemImage: "checkmark.circle.fill")
                }
            }

            // Other accounts
            let others = accountManager.accounts.filter { $0.username != accountManager.activeUsername }
            ForEach(others) { account in
                Button {
                    onSwitchAccount?(account.username)
                } label: {
                    Label(account.username, systemImage: "person.circle")
                }
            }

            Divider()

            Button {
                onAddAccount?()
            } label: {
                Label("添加账号", systemImage: "plus.circle")
            }

            if others.count > 0 {
                Button {
                    onManageAccounts?()
                } label: {
                    Label("账号管理", systemImage: "person.2")
                }
            }
        } else {
            Button {
                onAddAccount?()
            } label: {
                Label("登录", systemImage: "person.crop.circle.badge.plus")
            }
        }
    }
}
