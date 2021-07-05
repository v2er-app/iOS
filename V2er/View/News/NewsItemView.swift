//
//  NewsItemView.swift
//  V2er
//
//  Created by Seth on 2021/7/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsItemView: View {
    
    
    var body: some View {
        VStack {
            VStack {
                HStack(alignment: .top) {
                    Image("avar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48)
                        .roundedEdge()
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ghui")
                            .lineLimit(1)
                            .font(.body)
                        Text("51分钟前 评论3")
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    Spacer()
                    Text("问与答")
                        .font(.footnote)
                        .lineLimit(1)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.lightGray)
                }
                Text("有人用非等宽字体来写代码的吗？等宽字体显示代码有什么特殊的好处吗？")
                    .lineLimit(2)
            }
            .padding(10)
            Divider()
        }
    }
}

struct NewsItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewsItemView()
    }
}
