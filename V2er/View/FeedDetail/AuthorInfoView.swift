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
    var onNavigate: ((AppRoute) -> Void)? = nil
    @Environment(\.iPadDetailRoute) private var iPadDetailRoute
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
                    navigate(to: .userDetail(userId: userName))
                } label: {
                    AvatarView(url: avatar, size: 42)
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: Spacing.xs + 2) {
                    Text(userName)
                        .lineLimit(1)
                    Text(replyNum + timeAndClickedNum)
                        .lineLimit(1)
                        .font(AppFont.timestamp)
                        .foregroundColor(.secondaryText)
                }
                Spacer()
                Button {
                    navigate(to: .tagDetailWithName(tag: tag, tagId: tagId))
                } label: {
                    Text(tag)
                        .nodeBadgeStyle()
                }
                .buttonStyle(.plain)
            }
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .padding(.top, Spacing.lg)
        }
        .padding(Spacing.md)
        .accessibilityElement(children: .combine)
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
    }

    private func navigate(to route: AppRoute) {
        if let onNavigate {
            onNavigate(route)
        } else if let detailRoute = iPadDetailRoute {
            detailRoute.wrappedValue = route
        } else {
            navigateToRoute = route
        }
    }
}
