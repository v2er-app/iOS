//
//  Routes.swift
//  V2er
//
//  Centralized navigation route definitions.
//  Used with NavigationStack + .navigationDestination(for:).
//

import SwiftUI

/// All navigable routes in the app.
/// Each case carries only the minimal Hashable data needed to construct the destination.
enum AppRoute: Hashable {
    // MARK: - Feed & Content
    case feedDetail(id: String)
    case tagDetail(tagId: String)
    case tagDetailWithName(tag: String, tagId: String)

    // MARK: - User
    case userDetail(userId: String)
    case userFeed(userId: String)

    // MARK: - My Content
    case myFavorites
    case myFollow
    case myRecent
    case myUploads
    case createTopic

    // MARK: - Other Apps
    case allOtherApps

    // MARK: - Settings
    case settings
    case appearanceSettings
    case otherSettings
    case credits
    case browseSettings

    // MARK: - Browser
    case webBrowser(url: String)
    case inAppBrowser(url: URL)
    case safariView(url: URL)
}

// MARK: - Destination Builder

extension AppRoute {
    /// Builds the destination view for a given route.
    /// Injects Store.shared to guarantee availability across NavigationStack boundaries.
    func destination() -> some View {
        _destinationContent()
            .environmentObject(Store.shared)
    }

    @ViewBuilder
    private func _destinationContent() -> some View {
        switch self {
        case .feedDetail(let id):
            FeedDetailPage(id: id)
        case .tagDetail(let tagId):
            TagDetailPage(tagId: tagId)
        case .tagDetailWithName(let tag, let tagId):
            TagDetailPage(tag: tag, tagId: tagId)
        case .userDetail(let userId):
            UserDetailPage(userId: userId)
        case .userFeed(let userId):
            UserFeedPage(userId: userId)
        case .myFavorites:
            MyFavoritePage()
        case .myFollow:
            MyFollowPage()
        case .myRecent:
            MyRecentPage()
        case .myUploads:
            MyUploadsPage()
        case .createTopic:
            CreateTopicPage()
        case .allOtherApps:
            AllOtherAppsPage()
        case .settings:
            SettingsPage()
        case .appearanceSettings:
            AppearanceSettingView()
        case .otherSettings:
            OtherSettingsView()
        case .credits:
            CreditsPage()
        case .browseSettings:
            BrowseSettingView()
        case .webBrowser(let url):
            WebBrowserView(url: url)
        case .inAppBrowser(let url):
            InAppBrowserView(url: url)
        case .safariView(let url):
            #if os(iOS)
            SafariView(url: url)
                .ignoresSafeArea()
                .navigationBarHidden(true)
            #else
            InAppBrowserView(url: url)
            #endif
        }
    }
}

// MARK: - URL Identifiable conformance for .navigationDestination(item:)

#if swift(>=5.10)
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
#else
extension URL: Identifiable {
    public var id: String { absoluteString }
}
#endif

// MARK: - AppRoute Identifiable conformance for .navigationDestination(item:)

extension AppRoute: Identifiable {
    var id: Self { self }
}

// MARK: - FeedDetail with initData

/// Special route for feed detail that carries pre-populated data.
/// Separated from AppRoute because FeedInfo.Item is not Hashable.
struct FeedDetailRoute: Identifiable {
    let id: String
    let initData: FeedInfo.Item?

    init(initData: FeedInfo.Item) {
        self.id = initData.id
        self.initData = initData
    }

    init(id: String) {
        self.id = id
        self.initData = nil
    }
}
