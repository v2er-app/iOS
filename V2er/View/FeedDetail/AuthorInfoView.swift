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
//    var data

    private var title: String {
        initData?.title ?? .empty
    }

    private var tag: String {
        initData?.tagName ?? .empty
    }

    private var tagId: String {
        initData?.tagId ?? .empty
    }

    private var userName: String {
        initData?.userName ?? .empty
    }

    private var avatar: String {
        initData?.avatar ?? .empty
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(alignment: .top) {
                    NavigationLink(destination: UserDetailPage()) {
                        AvatarView(url: avatar, size: 48)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(userName)
                            .lineLimit(1)
                            .font(.body)
                        Text("51分钟前 评论3 点击667")
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
            Divider()
        }
    }
}

struct AuthorInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorInfoView()
    }
}
