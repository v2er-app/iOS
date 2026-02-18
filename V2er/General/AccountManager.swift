//
//  AccountManager.swift
//  V2er
//
//  Multi-account manager: archives/restores cookies per account for lightweight switching.
//

import Foundation

struct StoredAccount: Codable, Identifiable {
    var id: String { username }
    var username: String
    var avatar: String
    var balance: BalanceInfo?
    var archivedCookies: [Data]
    var addedAt: Date

    var accountInfo: AccountInfo {
        AccountInfo(username: username, avatar: avatar, balance: balance)
    }

    init(from account: AccountInfo, cookies: [Data] = [], addedAt: Date = Date()) {
        self.username = account.username
        self.avatar = account.avatar
        self.balance = account.balance
        self.archivedCookies = cookies
        self.addedAt = addedAt
    }
}

final class AccountManager: ObservableObject {
    static let shared = AccountManager()

    private static let accountsKey = "app.v2er.accounts"
    private static let activeUsernameKey = "app.v2er.accounts.active"
    private static let legacyAccountKey = "app.v2er.account"

    @Published var accounts: [StoredAccount] = []
    @Published var activeUsername: String?

    var currentAccount: StoredAccount? {
        accounts.first { $0.username == activeUsername }
    }

    var currentAccountInfo: AccountInfo? {
        currentAccount?.accountInfo
    }

    private init() {
        loadAccounts()
        migrateLegacyAccountIfNeeded()
    }

    // MARK: - Save / Update

    func saveAccount(_ account: AccountInfo) {
        let cookies = archiveCurrentCookies()
        if let index = accounts.firstIndex(where: { $0.username == account.username }) {
            accounts[index].avatar = account.avatar
            accounts[index].balance = account.balance
            accounts[index].archivedCookies = cookies
        } else {
            let stored = StoredAccount(from: account, cookies: cookies)
            accounts.append(stored)
        }
        activeUsername = account.username
        persistAccounts()
    }

    func updateBalance(_ balance: BalanceInfo) {
        guard let username = activeUsername,
              let index = accounts.firstIndex(where: { $0.username == username }) else { return }
        accounts[index].balance = balance
        persistAccounts()
    }

    // MARK: - Switch Account

    func switchTo(username: String) {
        guard username != activeUsername,
              let targetIndex = accounts.firstIndex(where: { $0.username == username }) else { return }

        // Archive current account's cookies
        if let currentIndex = accounts.firstIndex(where: { $0.username == activeUsername }) {
            accounts[currentIndex].archivedCookies = archiveCurrentCookies()
        }

        // Clear cookie jar
        APIService.shared.clearCookie()

        // Restore target account's cookies
        restoreCookies(accounts[targetIndex].archivedCookies)

        // Update active
        activeUsername = username
        persistAccounts()

        // Reset user-specific state and reload feed
        resetAppStateForSwitch()
    }

    // MARK: - Remove Account

    func removeAccount(username: String) {
        accounts.removeAll { $0.username == username }

        // Clean up per-user Keychain token
        SettingState.deleteV2exAccessToken(forUser: username)

        if username == activeUsername {
            if let next = accounts.first {
                switchTo(username: next.username)
            } else {
                // No accounts left — go logged-out
                activeUsername = nil
                APIService.shared.clearCookie()
                resetAppStateForSwitch()
            }
        }
        persistAccounts()
    }

    /// Archives the current account's cookies before a new login flow starts.
    /// Must be called before showing the login page for "Add Account",
    /// otherwise the login flow's Set-Cookie will overwrite the current session.
    func archiveCurrentAccountCookies() {
        guard let username = activeUsername,
              let index = accounts.firstIndex(where: { $0.username == username }) else { return }
        accounts[index].archivedCookies = archiveCurrentCookies()
        persistAccounts()
    }

    // MARK: - Cookie Archival

    private func archiveCurrentCookies() -> [Data] {
        let storage = HTTPCookieStorage.shared
        guard let cookies = storage.cookies(for: APIService.baseURL) else { return [] }
        return cookies.compactMap { cookie -> Data? in
            guard let properties = cookie.properties else { return nil }
            return try? NSKeyedArchiver.archivedData(withRootObject: properties, requiringSecureCoding: false)
        }
    }

    private func restoreCookies(_ cookieData: [Data]) {
        let storage = HTTPCookieStorage.shared
        for data in cookieData {
            guard let properties = try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSDictionary.self, from: data
            ) as? [HTTPCookiePropertyKey: Any],
                  let cookie = HTTPCookie(properties: properties) else { continue }
            storage.setCookie(cookie)
        }
    }

    // MARK: - State Reset

    private func resetAppStateForSwitch() {
        DispatchQueue.main.async {
            let store = Store.shared
            store.appState.feedState = FeedState()
            store.appState.messageState = MessageState()
            store.appState.meState = MeState()
            store.appState.myFavoriteState = MyFavoriteState()
            store.appState.myFollowState = MyFollowState()
            store.appState.myRecentState = MyRecentState()
            store.appState.feedDetailStates = [:]
            store.appState.userDetailStates = [:]
            store.appState.userFeedStates = [:]
            // Reload V2EX access token for new account
            store.appState.settingState.v2exAccessToken = SettingState.getRawV2exAccessToken() ?? ""
            // Trigger feed reload
            dispatch(FeedActions.FetchData.Start())
        }
    }

    // MARK: - Persistence

    private func persistAccounts() {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        UserDefaults.standard.set(data, forKey: Self.accountsKey)
        UserDefaults.standard.set(activeUsername, forKey: Self.activeUsernameKey)
    }

    private func loadAccounts() {
        guard let data = UserDefaults.standard.data(forKey: Self.accountsKey),
              let decoded = try? JSONDecoder().decode([StoredAccount].self, from: data) else { return }
        accounts = decoded
        activeUsername = UserDefaults.standard.string(forKey: Self.activeUsernameKey)
    }

    // MARK: - Legacy Migration

    private func migrateLegacyAccountIfNeeded() {
        // Skip if already migrated (new-format accounts exist)
        guard accounts.isEmpty else { return }

        // Read legacy single-account data
        guard let legacyData = UserDefaults.standard.data(forKey: Self.legacyAccountKey),
              let legacyAccount = try? JSONDecoder().decode(AccountInfo.self, from: legacyData) else { return }

        guard legacyAccount.isValid() else { return }

        // Create StoredAccount with current cookies
        let cookies = archiveCurrentCookies()
        let stored = StoredAccount(from: legacyAccount, cookies: cookies)
        accounts = [stored]
        activeUsername = legacyAccount.username

        // Migrate Keychain token to per-user key
        SettingState.migrateLegacyToken(toUser: legacyAccount.username)

        persistAccounts()

        // Clear legacy key
        UserDefaults.standard.removeObject(forKey: Self.legacyAccountKey)

        log("Migrated legacy account: \(legacyAccount.username)")
    }
}
