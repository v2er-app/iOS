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
                    NodeView(id: data.nodeId.safe, name: data.nodeName.safe)
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
        .background(Color.itemBg)
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

//struct NewsItemView_Previews: PreviewProvider {
//    static var previews: some View {
////        NewsItemView()
//    }
//}
