//
//  MessagePage.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct MessagePage: View {
    var selecedTab: TabId
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach( 0...20, id: \.self) { i in
                NavigationLink(destination: FeedDetailPage()) {
                    MessageItemView()
                }
            }
        }
        .background(Color.pageLight)
        .updatable(
            refresh:{
                print("onRefresh...")
            },
            loadMore: {
                print("onLoadMore...")
            }
        )
        .opacity(selecedTab == .message ? 1.0 : 0.0)
    }
}

fileprivate struct MessageItemView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top,spacing: 8) {
                AvatarView(size: 40)
                VStack(alignment: .leading) {
                    Text("kevinsnow 在回复 Mac mini m1 用微信的时候总是识别不了摄像头 时提到了你")
                        .font(.subheadline)
                    Text("@ghui 是直接插在机身的 usb 上面的")
                        .greedyWidth(.leading)
                        .font(.footnote)
                        .padding(10)
                        .background {
                            HStack(spacing: 0) {
                                Color.tintColor.opacity(0.8)
                                    .frame(width: 3)
                                Color.lightGray
                            }
                        }
                }
            }
            .padding(10)
            Divider()
        }
    }
}

struct MessagePage_Previews: PreviewProvider {
    static var selected = TabId.message
    static var previews: some View {
        MainPage()
            .environmentObject(Store.shared)
    }
}
