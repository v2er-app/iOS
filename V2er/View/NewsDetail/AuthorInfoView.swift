//
//  AuthorInfoView.swift
//  V2er
//
//  Created by Seth on 2021/7/7.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct AuthorInfoView: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(alignment: .top) {
                    NavigationLink(destination: UserDetailPage()) {
                        AvatarView(size: 48)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ghui")
                            .lineLimit(1)
                            .font(.body)
                        Text("51分钟前 评论3 点击667")
                            .lineLimit(1)
                            .font(.caption2)
                    }
                    Spacer()
                    NavigationLink(destination: TagDetailPage()) {
                        Text("问与答")
                            .font(.footnote)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.lightGray)
                    }
                }
                Text("计算机经历几十年 CURD，难道没有一个大而全的解决方案吗？")
                    .font(.subheadline)
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
