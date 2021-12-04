//
//  Endpoint.swift
//  Endpoint
//
//  Created by ghui on 2021/8/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

enum Endpoint {
    enum ResourceType {
        case html
        case json
    }
    case tab, recent, explore
    case captcha, signin
    case topic(id: String), topics(userName: String)
    case myFollowing, message
    case myFavoriteNodes, myFavoriteFeeds
    case nodesNav, nodes
    case tagDetail(tagId: String)
    case userPage(userName: String), createTopic
    case appendTopic(id: String), thanksReply(id: String)
    case thanksAuthor(id: String), sendMoney
    case starTopic(id: String)
    case unStarTopic(id: String), ignoreTopic(id: String)
    case ignoreReply(id: String), ignoreNode(id: String)
    case unIgnoreNode(id: String), upTopic(id: String), downTopic(id: String)
    case replyTopic(id: String), blockUser(id: String)
    case followUser(id: String), unfollowUser(id: String)
    case starNode(id: String), dailyMission
    case checkin, downMyTopic(id: String), pinTopic(id: String)
    case search
    case general(url: String)

    func path() -> String {
        return info().path
    }

    var url: URL {
        var url: URL
        let path = info().path
        if path.starts(with: "http") {
            url = URL(string: path)!
        } else {
            url =  APIService.baseURL.appendingPathComponent(path)
        }
        return url
    }

    func type() -> ResourceType {
        return info().type
    }

    func ua() -> UA {
        return info().ua
    }

    func queries() -> Params {
        info().queries
    }

    typealias Info = (path: String, type: ResourceType, ua: UA, queries: Params)

    private func info() -> Info {
        var info: Info = ("", .html, .wap, [:])
        switch self {
            case .tab:
                info.path = "/"
            case .recent:
                info.path = "/recent"
            case .explore:
                info.path = "/"
                info.ua = .web
            case .captcha:
                info.path = "/signin"
//                info.queries["next"] = "/mission/daily"
            case .signin:
                info.path = "/signin"
            case let .topic(id):
                info.path = "/t/\(id)"
            case let .topics(userName):
                info.path = "/member/\(userName)/topics"
            case .message:
                info.path = "/notifications"
                info.ua = .web
            case .myFollowing:
                info.path = "/my/following"
            case .myFavoriteFeeds:
                info.path = "/my/topics"
            case .myFavoriteNodes:
                info.path = "/my/nodes"
            case .nodesNav:
                info.path = "/"
            case .nodes:
                info.path = "/api/nodes/s2.json"
                info.type = .json
            case let .tagDetail(nodeName):
                info.path = "/go/\(nodeName)"
                info.ua = .web
            case let .userPage(userName):
                info.path = "/member/\(userName)"
            case .createTopic:
                info.path = "/write"
            case let .appendTopic(id):
                info.path = "/append/topic/\(id)"
            case let .thanksReply(id):
                info.path = "/thank/reply/\(id)"
            case let .thanksAuthor(id):
                info.path = "/thank/topic/\(id)"
            case .sendMoney:
                info.path = "/ajax/money"
            case let .starTopic(id):
                info.path = "/favorite/topic/\(id)"
            case let .unStarTopic(id):
                info.path = "/unfavorite/topic/\(id)"
            case let .ignoreTopic(id):
                info.path = "/ignore/topic/\(id)"
            case let .ignoreReply(id):
                info.path = "/ignore/reply/\(id)"
            case let .ignoreNode(id):
                info.path = "/settings/ignore/node/\(id)"
            case let .unIgnoreNode(id):
                info.path = "/settings/unignore/node/\(id)"
            case let .upTopic(id):
                info.path = "/up/topic/\(id)"
            case let .downTopic(id):
                info.path = "/down/topic/\(id)"
            case let .replyTopic(id):
                info.path = "/t/\(id)"
            case let .blockUser(id):
                info.path = "/block/\(id)"
            case let .followUser(id):
                info.path = "/follow/\(id)"
            case let .unfollowUser(id):
                info.path = "/unfollow/\(id)"
            case let .starNode(id):
                info.path = "/favorite/node/\(id)"
            case .dailyMission:
                info.path = "/mission/daily"
            case .checkin:
                info.path = "/mission/daily/redeem"
//            case .twoFA:
//                info.path = "/2fa?next=/mission/daily"
            case let .downMyTopic(id):
                info.path = "/fade/topic/\(id)"
            case let .pinTopic(id):
                info.path = "/sticky/topic/\(id)"
            case let .search:
                info.path = "https://www.sov2ex.com/api/search"
            case let .general(url):
                // check whether url contains params
                if url.contains("?") {
                    info.queries = URL(string: url)!.params()
                    info.path = url.segment(separatedBy: "?", at: .first)
                } else {
                    info.path = url
                }
        }
        return info
    }

}
