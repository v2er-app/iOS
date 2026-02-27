//
//  AccountManager.swift
//  V2er
//
//  Multi-account manager: archives/restores cookies per account for lightweight switching.
//

import Combine
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
    /// Cross-component signal: set to `true` to open the account management sheet from anywhere.
    @Published var showSwitcher = false

    var currentAccount: StoredAccount? {
        accounts.first { $0.username == activeUsername }
    }

    var currentAccountInfo: AccountInfo? {
        currentAccount?.accountInfo
    }

    private init() {
        loadAccounts()
        migrateLegacyAccountIfNeeded()
        restoreActiveAccountCookiesIfNeeded()
    }

    // MARK: - Save / Update

    func saveAccount(_ account: AccountInfo) {
        // NOTE: Do NOT re-archive the previous user's cookies here.
        // By the time saveAccount is called (after login completes), the cookie jar
        // already contains the NEW user's cookies. Archiving now would overwrite
        // the previous user's valid cookies with the wrong session.
        // The previous user's cookies are archived in archiveCurrentAccountCookies()
        // which is called BEFORE the login flow starts.

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

    /// Keeps the active account's cookie archive in sync with the live cookie jar.
    /// Call this periodically (e.g. on app background) so archived cookies stay fresh.
    func refreshArchivedCookiesForActiveAccount() {
        guard let username = activeUsername,
              let index = accounts.firstIndex(where: { $0.username == username }) else { return }
        let fresh = archiveCurrentCookies()
        guard !fresh.isEmpty else { return }
        accounts[index].archivedCookies = fresh
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
            // Must match archiveCurrentCookies' requiringSecureCoding: false,
            // otherwise the mixed value types in cookie properties (NSString,
            // NSDate, NSNumber, etc.) cause the unarchiver to silently fail.
            guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else { continue }
            defer { unarchiver.finishDecoding() }
            unarchiver.requiresSecureCoding = false
            guard var properties = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey)
                    as? [HTTPCookiePropertyKey: Any] else { continue }

            // Session cookies (no Expires) are discarded by HTTPCookieStorage on app termination.
            // Promote them to persistent cookies so they survive across launches.
            if properties[.expires] == nil || properties[.discard] as? String == "TRUE" {
                properties[.expires] = Date(timeIntervalSinceNow: 365 * 24 * 60 * 60)
                properties.removeValue(forKey: .discard)
            }

            guard let cookie = HTTPCookie(properties: properties) else { continue }
            storage.setCookie(cookie)
        }
    }

    /// On cold launch, the cookie jar may be empty (session cookies don't persist).
    /// Restore the active account's cookies so the first API request succeeds.
    private func restoreActiveAccountCookiesIfNeeded() {
        guard let username = activeUsername,
              let account = accounts.first(where: { $0.username == username }),
              !account.archivedCookies.isEmpty else { return }

        let storage = HTTPCookieStorage.shared
        let existing = storage.cookies(for: APIService.baseURL) ?? []
        if existing.isEmpty {
            log("Restoring cookies for \(username) on launch (jar was empty)")
            restoreCookies(account.archivedCookies)
        }
    }

    // MARK: - State Reset

    private func resetAppStateForSwitch() {
        let store = Store.shared
        // Reset all user-specific in-memory state
        store.appState.loginState = LoginState()
        store.appState.feedState = FeedState()
        store.appState.feedState.selectedTab = .all  // Reset to safe default; the persisted tab may require login
        store.appState.messageState = MessageState()
        store.appState.meState = MeState()
        store.appState.myFavoriteState = MyFavoriteState()
        store.appState.myFollowState = MyFollowState()
        store.appState.myRecentState = MyRecentState()
        store.appState.exploreState = ExploreState()
        store.appState.createTopicState = CreateTopicState()
        store.appState.searchState = SearchState()
        store.appState.feedDetailStates = [:]
        store.appState.userDetailStates = [:]
        store.appState.userFeedStates = [:]
        store.appState.tagDetailStates = [:]
        // Reload per-user V2EX access token, token-enabled preference, and checkin state
        store.appState.settingState.v2exAccessToken = SettingState.getRawV2exAccessToken() ?? ""
        if let enabledValue = UserDefaults.standard.object(forKey: SettingState.v2exTokenEnabledKey) {
            store.appState.settingState.v2exTokenEnabled = (enabledValue as? Bool) ?? true
        } else {
            store.appState.settingState.v2exTokenEnabled = true  // Default: enabled
        }
        store.appState.settingState.lastCheckinDate = UserDefaults.standard.object(forKey: SettingState.checkinDateKey) as? Date
        store.appState.settingState.checkinDays = UserDefaults.standard.integer(forKey: SettingState.checkinDaysKey)
        store.appState.settingState.isCheckingIn = false
        store.appState.settingState.checkinError = nil
        // Clear in-memory content caches
        if #available(iOS 18.0, *) {
            RichViewCache.shared.clearAll()
        }
        // Trigger feed reload
        dispatch(FeedActions.FetchData.Start())
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
        // If migration was interrupted, clean up the leftover legacy key
        if !accounts.isEmpty {
            UserDefaults.standard.removeObject(forKey: Self.legacyAccountKey)
            return
        }

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
