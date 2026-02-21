//
//  AccountSwitcherView.swift
//  V2er
//
//  Account switcher sheet: view, switch, and manage saved accounts.
//

import SwiftUI

struct AccountSwitcherView: View {
    @StateObject private var accountManager = AccountManager.shared
    @Environment(\.dismiss) private var dismiss
    @Binding var shouldAddAccount: Bool

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Current Account
                if let current = accountManager.currentAccount {
                    Section("当前账号") {
                        accountRow(current, isCurrent: true)
                    }
                }

                // MARK: - Other Accounts
                let others = accountManager.accounts.filter { $0.username != accountManager.activeUsername }
                if !others.isEmpty {
                    Section("其他账号") {
                        ForEach(others) { account in
                            accountRow(account, isCurrent: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    accountManager.switchTo(username: account.username)
                                    dismiss()
                                }
                        }
                        .onDelete { offsets in
                            let usernames = offsets.map { others[$0].username }
                            for username in usernames {
                                accountManager.removeAccount(username: username)
                            }
                        }
                    }
                }

                // MARK: - Add Account
                Section {
                    Button {
                        accountManager.archiveCurrentAccountCookies()
                        shouldAddAccount = true
                        dismiss()
                    } label: {
                        Label("添加账号", systemImage: "plus.circle")
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .navigationTitle("账号管理")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func accountRow(_ account: StoredAccount, isCurrent: Bool) -> some View {
        HStack(spacing: Spacing.md) {
            AvatarView(url: account.avatar, size: 40)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(account.username)
                    .font(.body.weight(.medium))
                if let balance = account.balance, balance.isValid() {
                    BalanceView(balance: balance, size: 11)
                }
            }

            Spacer()

            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}
