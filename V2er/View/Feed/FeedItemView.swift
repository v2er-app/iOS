//
//  NewsItemView.swift
//  V2er
//
//  Created by Seth on 2021/7/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedItemView<Data: FeedItemProtocol>: View {
    let data: Data
    @State private var navigateToRoute: AppRoute?

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button {
                    navigateToRoute = .userDetail(userId: data.userName.safe)
                } label: {
                    AvatarView(url: data.avatar)
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(data.userName.safe)
                        .font(AppFont.username)
                    Text(data.replyUpdate.safe)
                        .font(AppFont.timestamp)
                }
                .lineLimit(1)
                .foregroundColor(.accentColor)
                Spacer()
                Button {
                    navigateToRoute = .tagDetail(tagId: data.nodeId.safe)
                } label: {
                    Text(data.nodeName.safe)
                        .nodeBadgeStyle()
                }
                .buttonStyle(.plain)
            }
            Text(data.title.safe)
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .lineLimit(2)
                .padding(.top, Spacing.sm - 2)
                .padding(.vertical, Spacing.xs)
            Text("评论\(data.replyNum.safe)")
                .font(AppFont.metadata)
                .foregroundColor(.secondaryText)
                .greedyWidth(.trailing)
        }
        .padding(Spacing.md)
        .background(Color(.secondarySystemGroupedBackground))
        .divider()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(data.userName.safe), \(data.title.safe), \(data.nodeName.safe), \(data.replyNum.safe)条评论")
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
    }
}


protocol FeedItemProtocol: Identifiable {
    var id: String { get }
    var title: String? { get }
    var avatar: String? { get }
    var userName: String? { get }
    var replyUpdate: String? { get }
    var nodeName: String? { get }
    var nodeId: String? { get }
    var replyNum: String? { get }

    init(id: String, title: String?, avatar: String?)
}
