//
//  AccountUtil.swift
//  V2er
//
//  Created by ghui on 2021/9/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

/// Thin facade over AccountManager — preserves the existing static interface
/// used by 30+ call sites across the codebase.
struct AccountState {

    static func saveAccount(_ account: AccountInfo) {
        AccountManager.shared.saveAccount(account)
        log("account: \(account) saved")
    }

    static func deleteAccount() {
        guard let username = AccountManager.shared.activeUsername else {
            log("deleteAccount skipped: no active username")
            return
        }
        AccountManager.shared.removeAccount(username: username)
    }

    static func getAccount() -> AccountInfo? {
        return AccountManager.shared.currentAccountInfo
    }

    static func hasSignIn() -> Bool {
        return AccountManager.shared.currentAccount != nil
    }

    static var userName: String {
        return AccountManager.shared.activeUsername ?? .default
    }

    static var avatarUrl: String {
        return AccountManager.shared.currentAccount?.avatar ?? .default
    }

    static func isSelf(userName: String) -> Bool {
        return userName == Self.userName && userName != .default
    }

    static var balance: BalanceInfo? {
        return AccountManager.shared.currentAccount?.balance
    }

    static func updateBalance(_ balance: BalanceInfo) {
        AccountManager.shared.updateBalance(balance)
    }
}
