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
            AvatarView(url: info.avatar, size: 40)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack (alignment: .leading, spacing: 4) {
                        Text(info.userName)
                        Text(info.time)
                            .font(.caption2)
                    }
                    Spacer()
                    Image(systemName: "heart")
                }
                RichText { info.content }
                .debug()
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
