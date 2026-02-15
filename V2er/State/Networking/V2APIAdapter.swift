//
//  V2APIAdapter.swift
//  V2er
//
//  Converts V2EX API v2 models into existing app models (FeedDetailInfo).
//

import Foundation

enum V2APIAdapter {

    static func buildFeedDetailInfo(
        topic: V2Response<V2TopicDetail>,
        replies: V2Response<[V2ReplyDetail]>,
        page: Int,
        totalReplyCount: Int? = nil
    ) -> FeedDetailInfo {
        let t = topic.result
        let replyCount = totalReplyCount ?? t.replies ?? 0
        let totalPage = max((replyCount + 99) / 100, 1)

        var info = FeedDetailInfo()
        info.topicId = "\(t.id)"
        info.headerInfo = buildHeaderInfo(from: t, currentPage: page, totalPage: totalPage)
        info.contentInfo = buildContentInfo(from: t)
        info.replyInfo = buildReplyInfo(from: replies.result, owner: t.member?.username ?? "", page: page)
        return info
    }

    static func buildReplyPage(
        replies: V2Response<[V2ReplyDetail]>,
        owner: String,
        page: Int,
        totalPage: Int
    ) -> FeedDetailInfo {
        var info = FeedDetailInfo()
        info.headerInfo = FeedDetailInfo.HeaderInfo(id: "", title: nil, avatar: nil)
        info.headerInfo?.currentPage = page
        info.headerInfo?.totalPage = totalPage
        info.replyInfo = buildReplyInfo(from: replies.result, owner: owner, page: page)
        return info
    }

    // MARK: - Private Helpers

    private static func buildHeaderInfo(
        from topic: V2TopicDetail,
        currentPage: Int,
        totalPage: Int
    ) -> FeedDetailInfo.HeaderInfo {
        var header = FeedDetailInfo.HeaderInfo(
            id: "\(topic.id)",
            title: topic.title,
            avatar: parseAvatar(topic.member?.avatarNormal ?? topic.member?.avatar ?? "")
        )
        header.userName = topic.member?.username
        header.replyUpdate = formatTimestamp(topic.created)
        header.nodeName = topic.node?.title ?? topic.node?.name
        header.nodeId = topic.node?.name
        header.replyNum = topic.replies.map { "\($0)" }
        header.currentPage = currentPage
        header.totalPage = totalPage
        return header
    }

    private static func buildContentInfo(from topic: V2TopicDetail) -> FeedDetailInfo.ContentInfo {
        var content = FeedDetailInfo.ContentInfo()
        if let rendered = topic.contentRendered, rendered.notEmpty() {
            content.html = rendered
        } else if let raw = topic.content, raw.notEmpty() {
            content.html = raw
        }
        return content
    }

    private static func buildReplyInfo(
        from replies: [V2ReplyDetail],
        owner: String,
        page: Int
    ) -> FeedDetailInfo.ReplyInfo {
        var replyInfo = FeedDetailInfo.ReplyInfo()
        replyInfo.owner = owner
        for (index, reply) in replies.enumerated() {
            let floor = (page - 1) * 100 + index + 1
            var item = FeedDetailInfo.ReplyInfo.Item()
            item.floor = floor
            item.replyId = "r_\(reply.id)"
            item.content = reply.contentRendered ?? reply.content ?? ""
            item.userName = reply.member?.username ?? ""
            item.avatar = parseAvatar(reply.member?.avatarNormal ?? reply.member?.avatar ?? "")
            item.time = formatTimestamp(reply.created)
            item.owner = owner
            replyInfo.items.append(item)
        }
        return replyInfo
    }

    private static func formatTimestamp(_ timestamp: Int?) -> String {
        guard let ts = timestamp else { return "" }
        let date = Date(timeIntervalSince1970: TimeInterval(ts))
        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            return "\(Int(interval / 60)) 分钟前"
        } else if interval < 86400 {
            return "\(Int(interval / 3600)) 小时前"
        } else if interval < 86400 * 30 {
            return "\(Int(interval / 86400)) 天前"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
    }
}
