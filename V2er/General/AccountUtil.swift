//
//  AccountUtil.swift
//  V2er
//
//  Created by ghui on 2021/9/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct AccountUtil {
    static let ACCOUNT_KEY = "app.v2er.account"
    static func save(_ account: AccountInfo) {
        do {
            let jsonData = try JSONEncoder().encode(account)
            Persist.save(value: jsonData, forkey: ACCOUNT_KEY)
        } catch {
            log("Save account failed")
        }
    }

    static func readAccount() -> AccountInfo? {
        do {
            let data = Persist.read(key: ACCOUNT_KEY)
            guard let data = data else { return nil }
            let accountInfo = try JSONDecoder()
                .decode(AccountInfo.self, from: data)
            return accountInfo
        } catch {
            log("readAccount failed")
        }
        return nil
    }

    static func isAccountSignIn() -> Bool {
        let account = readAccount()
        guard let account = account else {
            return false
        }
        return account.isValid()
    }

}
