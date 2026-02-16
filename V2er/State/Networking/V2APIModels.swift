//
//  V2APIModels.swift
//  V2er
//
//  Codable models matching V2EX API v2 JSON responses.
//

import Foundation

struct V2Response<T: Decodable>: Decodable {
    let success: Bool
    let result: T
}

struct V2TopicDetail: Decodable {
    let id: Int
    let title: String?
    let content: String?
    let contentRendered: String?
    let created: Int?
    let lastModified: Int?
    let lastReplyBy: String?
    let replies: Int?
    let member: V2MemberBrief?
    let node: V2NodeBrief?
}

struct V2ReplyDetail: Decodable {
    let id: Int
    let content: String?
    let contentRendered: String?
    let created: Int?
    let member: V2MemberBrief?
}

struct V2MemberBrief: Decodable {
    let id: Int?
    let username: String?
    let avatar: String?
    let avatarMini: String?
    let avatarNormal: String?
    let avatarLarge: String?

    var bestAvatar: String {
        avatarLarge ?? avatarNormal ?? avatar ?? avatarMini ?? ""
    }
}

struct V2NodeBrief: Decodable {
    let name: String?
    let title: String?
    let url: String?
}

struct V2NodeDetail: Decodable {
    let id: Int
    let name: String
    let title: String?
    let url: String?
    let topics: Int?
    let stars: Int?
    let header: String?
    let footer: String?
    let titleAlternative: String?
    let avatarLarge: String?
    let avatarNormal: String?
    let avatarMini: String?
    let root: Bool?
    let parentNodeName: String?
    let aliases: [String]?
}

struct V2MemberDetail: Decodable {
    let id: Int
    let username: String?
    let url: String?
    let website: String?
    let twitter: String?
    let psn: String?
    let github: String?
    let btc: String?
    let location: String?
    let tagline: String?
    let bio: String?
    let avatar: String?
    let avatarMini: String?
    let avatarNormal: String?
    let avatarLarge: String?
    let created: Int?
    let lastModified: Int?
}

struct V2NotificationDetail: Decodable {
    let id: Int
    let memberId: Int?
    let forMemberId: Int?
    let text: String?
    let payload: String?
    let payloadRendered: String?
    let created: Int?
    let member: V2MemberBrief?
}
