//
//  AuthorInfoView.swift
//  V2er
//
//  Created by Seth on 2021/7/7.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct AuthorInfoView: View {
    var initData: FeedInfo.Item? = nil
    var data: FeedDetailInfo.HeaderInfo? = nil
    @State private var navigateToRoute: AppRoute?

    private var title: String {
        data?.title ?? initData?.title ?? .default
    }

    private var tag: String {
        data?.nodeName ?? initData?.nodeName ?? .default
    }

    private var tagId: String {
        data?.nodeId ?? initData?.nodeId ?? .default
    }

    private var userName: String {
        data?.userName ?? initData?.userName ?? .default
    }

    private var avatar: String {
        initData?.avatar ?? data?.avatar ?? .default
    }

    private var timeAndClickedNum: String {
        data?.replyUpdate ?? .default
    }

    private var replyNum: String {
        var result = (data?.replyNum ?? initData?.replyNum ?? .default)
        if result.notEmpty() {
            result = "评论\(result) "
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button {
                    navigateToRoute = .userDetail(userId: userName)
                } label: {
                    AvatarView(url: avatar, size: 38)
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(userName)
                        .lineLimit(1)
                    Text(replyNum + timeAndClickedNum)
                        .lineLimit(1)
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                }
                Spacer()
                Button {
                    navigateToRoute = .tagDetailWithName(tag: tag, tagId: tagId)
                } label: {
                    Text(tag)
                        .nodeBadgeStyle()
                }
                .buttonStyle(.plain)
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .padding(.top, Spacing.md)
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .accessibilityElement(children: .combine)
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
    }
}
