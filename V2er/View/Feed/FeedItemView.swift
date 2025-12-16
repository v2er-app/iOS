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
            HStack(alignment: .top) {
                AvatarView(url: data.avatar)
                VStack(alignment: .leading, spacing: 2) {
                    Text(data.userName.safe)
                        .font(.footnote)
                    Text(data.replyUpdate.safe)
                        .font(.caption2)
                }
                .lineLimit(1)
                .foregroundColor(Color.tintColor)
                Spacer()
                Text(data.nodeName.safe)
                    .font(.footnote)
                    .foregroundColor(Color.dynamic(light: .hex(0x666666), dark: .hex(0xCCCCCC)))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.dynamic(light: Color.hex(0xF5F5F5), dark: Color.hex(0x2C2C2E)))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .to { TagDetailPage(tagId: data.nodeId.safe) }
            }
            Text(data.title.safe)
//                .fontWeight(.medium)
                .foregroundColor(.primaryText)
                .greedyWidth(.leading)
                .lineLimit(2)
                .padding(.top, 6)
                .padding(.vertical, 4)
            Text("评论\(data.replyNum.safe)")
                .font(.footnote)
                .foregroundColor(.secondaryText)
                .greedyWidth(.trailing)
        }
        .padding(12)
        .background(Color.itemBg)
        .divider()

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
//        Text("Default Text")
//            .greedyWidth(.leading)
//            .lineLimit(2)
//            .padding(.vertical, 3)
//    }
//}
