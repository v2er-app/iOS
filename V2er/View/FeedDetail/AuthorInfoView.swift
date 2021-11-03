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
            result = " • 评论\(result)"
        }
        return result
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                NavigationLink(destination: UserDetailPage()) {
                    AvatarView(url: avatar, size: 48)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(userName)
                        .lineLimit(1)
                    Text(timeAndClickedNum + replyNum)
                        .lineLimit(1)
                        .font(.caption2)
                }
                Spacer()
                NavigationLink(destination: TagDetailPage(tag: tag, tagId: tagId)) {
                    Text(tag)
                        .font(.footnote)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.lightGray)
                }
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.bodyText)
                .greedyWidth(.leading)
        }
        .padding(10)
        .background(Color.itemBg)
    }
}

struct AuthorInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorInfoView()
    }
}
