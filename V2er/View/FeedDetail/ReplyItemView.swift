//
//  ReplyListView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Atributika


struct ReplyItemView: View {
    var info: FeedDetailInfo.ReplyInfo.Item

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 0) {
                AvatarView(url: info.avatar, size: 36)
                    .to { UserDetailPage(userId: info.userName) }
                Text("楼主")
                    .font(.system(size: 8))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .cornerBorder(radius: 3, borderWidth: 0.8, color: .black)
                    .padding(.top, 2)
                    .hide(!info.isOwner)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack (alignment: .leading, spacing: 4) {
                        Text(info.userName)
                        Text(info.time)
                            .font(.caption2)
                    }
                    Spacer()
                    //                    Image(systemName: "heart")
                }
                RichText { info.content }
                Text("\(info.floor)楼")
                    .font(.footnote)
                    .foregroundColor(Color.tintColor)
                Divider()
                    .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 12)
    }
}
