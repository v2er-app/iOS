//
//  AccountUtil.swift
//  V2er
//
//  Created by ghui on 2021/9/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct AccountState {
    static let ACCOUNT_KEY = "app.v2er.account"
    static var ACCOUNT: AccountInfo?

    static func saveAccount(_ account: AccountInfo) {
        do {
            let jsonData = try JSONEncoder().encode(account)
            Persist.save(value: jsonData, forkey: AccountState.ACCOUNT_KEY)
            log("account: \(account) saved")
            ACCOUNT = account
        } catch {
            log("Save account failed")
        }
    }

    static func deleteAccount() {
        Persist.save(value: String.empty, forkey: AccountState.ACCOUNT_KEY)
        ACCOUNT = nil
        APIService.shared.clearCookie()
    }

    static func getAccount() -> AccountInfo? {
        do {
            if ACCOUNT != nil { return ACCOUNT }
            let data = Persist.read(key: ACCOUNT_KEY)
            guard let data = data else { return nil }
            ACCOUNT = try JSONDecoder()
                .decode(AccountInfo.self, from: data)
            return ACCOUNT
        } catch {
            log("readAccount failed")
        }
        return nil
    }

    static func hasSignIn() -> Bool {
        return getAccount() != nil
    }

    static var userName: String {
        return getAccount()?.username ?? .default
    }

    static var avatarUrl: String {
        return getAccount()?.avatar ?? .default
    }

    static func isSelf(userName: String) -> Bool {
        return userName == Self.userName && userName != .default
    }

}
