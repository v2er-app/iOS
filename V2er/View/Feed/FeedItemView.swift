//
//  NewsItemView.swift
//  V2er
//
//  Created by Seth on 2021/7/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedItemView<Data: FeedItemInfo>: View {
    let data: Data
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    NavigationLink(destination: UserDetailPage(userId: data.userName)) {
                        AvatarView(url: data.avatar)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(data.userName.safe)
                            .lineLimit(1)
                            .font(.body)
                        Text(data.replyUpdate.safe)
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundColor(Color.tintColor)
                    }
                    Spacer()
                    NavigationLink(destination: TagDetailPage(tagId: data.tagId)) {
                        Text(data.tagName.safe)
                            .font(.footnote)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.lightGray)
                    }
                }
                Text(data.title.safe)
                    .greedyWidth(.leading)
                    .lineLimit(2)
                    .padding(.vertical, 3)
                Text("评论\(data.replyNum.safe)")
                    .font(.footnote)
                    .greedyWidth(.trailing)
            }
            .padding(12)
            Divider()
        }
        .background(Color.almostClear)
    }
}


protocol FeedItemInfo: Identifiable {
    var id: String { get }
    var title: String? { get }
    var avatar: String? { get }
    var userName: String? { get }
    var replyUpdate: String? { get }
    var tagName: String? { get }
    var tagId: String? { get }
    var replyNum: String? { get }
    
    init(id: String)
}

//struct NewsItemView_Previews: PreviewProvider {
//    static var previews: some View {
////        NewsItemView()
//    }
//}
