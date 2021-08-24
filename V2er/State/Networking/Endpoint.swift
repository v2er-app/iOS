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

    case tab, recent
    case signin, topic(topicId: String), notifications
    case myFollowing, myTopics, myNodes, nodesNav
    case nodeListDetail(nodeName: String)
    case userPage(userName: String), createTopic
    case appendTopic(id: String), thanksReply(id: String)
    case thanksAuthor(id: String), starTopic(id: String)
    case unStarTopic(id: String), ignoreTopic(id: String)
    case ignoreReply(id: String), ignoreNode(id: String)
    case unIgnoreNode(id: String), upTopic(id: String), downTopic(id: String)
    case replyTopic(id: String), blockUser(id: String)
    case followUser(id: String), starNode(id: String), dailyMission
    case checkin, twoFA, downMyTopic(id: String), pinTopic(id: String)

    func path() -> String {
        return info().0
    }

    func type() -> ResourceType {
        return info().1
    }

    private func info() -> (String, ResourceType) {
        switch self {
            case .tab:
                return ("/", .html)
            case .recent:
                return ("/recent", .html)
            case .signin:
                return ("/signin", .html)
            case let .topic(id):
                return ("/t\(id)", .html)
            case .notifications:
                return ("/notifications", .html)
            case .myFollowing:
                return ("/my/following", .html)
            case .myTopics:
                return ("/my/topics", .html)
            case .myNodes:
                return ("/my/nodes", .html)
            case .nodesNav:
                return ("/", .html)
            case let .nodeListDetail(nodeName):
                return ("/go/\(nodeName)", .html)
            case let .userPage(userName):
                return ("/member/\(userName)", .html)
            case .createTopic:
                return ("/new", .html)
            case let .appendTopic(id):
                return ("/append/topic/\(id)", .html)
            case let .thanksReply(id):
                return ("/thank/reply/\(id)", .html)
            case let .thanksAuthor(id):
                return ("/thank/topic/\(id)", .html)
            case let .starTopic(id):
                return ("/favorite/topic/\(id)", .html)
            case let .unStarTopic(id):
                return ("/unfavorite/topic/\(id)", .html)
            case let .ignoreTopic(id):
                return ("/ignore/topic/\(id)", .html)
            case let .ignoreReply(id):
                return ("ignore/reply/\(id)", .html)
            case let .ignoreNode(id):
                return ("/settings/ignore/node/\(id)", .html)
            case let .unIgnoreNode(id):
                return ("/settings/unignore/node/\(id)", .html)
            case let .upTopic(id):
                return ("/up/topic/\(id)", .html)
            case let .downTopic(id):
                return ("/down/topic/\(id)", .html)
            case let .replyTopic(id):
                return ("/t/\(id)", .html)
            case let .blockUser(id):
                return ("/block/\(id)", .html)
            case let .followUser(id):
                return ("/follow/\(id)", .html)
            case let .starNode(id):
                return ("/favorite/node/\(id)", .html)
            case .dailyMission:
                return ("/mission/daily", .html)
            case .checkin:
                return ("mission/daily/redeem", .html)
            case .twoFA:
                return ("/2fa?next=/mission/daily", .html)
            case let .downMyTopic(id):
                return ("/fade/topic/\(id)", .html)
            case let .pinTopic(id):
                return ("/sticky/topic/\(id)", .html)
        }
    }

}
