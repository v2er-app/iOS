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
    let avatarNormal: String?
}

struct V2NodeBrief: Decodable {
    let name: String?
    let title: String?
    let url: String?
}
