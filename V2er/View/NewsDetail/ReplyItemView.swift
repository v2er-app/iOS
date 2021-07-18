//
//  ReplyListView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI


struct ReplyItemView: View {
    var index: Int = 0
    
    var body: some View {
        HStack(alignment: .top) {
            AvatarView(size: 40)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack (alignment: .leading, spacing: 4) {
                        Text("ghui")
                        Text("1小时前")
                            .font(.caption2)
                    }
                    Spacer()
                    Image(systemName: "heart")
                    
                }
                Text("十几年前搞过一个生成 PHP 的东西，填几个表和数据库字段就自动生成 sql，管理后台和 api 接口以及前端的请求，想不到这么多年了，还没有傻瓜工具出来，是后端人员太便宜了还是需求不够多？")
                    .font(.subheadline)
                    .foregroundColor(.bodyText)
                
                Divider()
                    .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 12)
    }
}




struct ReplyListView_Previews: PreviewProvider {
    static var previews: some View {
        ReplyItemView()
    }
}
