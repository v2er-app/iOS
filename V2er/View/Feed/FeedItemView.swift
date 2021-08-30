//
//  NewsItemView.swift
//  V2er
//
//  Created by Seth on 2021/7/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedItemView: View {
    @Binding var data: FeedInfo.Item
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(alignment: .top) {
                    NavigationLink(destination: UserDetailPage()) {
                        AvatarView(url: data.avatar)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(data.userName)
                            .lineLimit(1)
                            .font(.body)
                        Text(data.time)
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    Spacer()
                    NavigationLink(destination: TagDetailPage()) {
                        Text(data.tagName)
                            .font(.footnote)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.lightGray)
                    }
                }
                Text(data.title )
                    .greedyWidth(.leading)
                    .lineLimit(2)
                    .debug()
            }
            .padding(10)
            Divider()
        }
        .background(Color.almostClear)
    }
}

//struct NewsItemView_Previews: PreviewProvider {
//    static var previews: some View {
////        NewsItemView()
//    }
//}
