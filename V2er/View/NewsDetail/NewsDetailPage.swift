//
//  NewsDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsDetailPage: View {
    var body: some View {
        LazyVStack(spacing: 0) {
            AuthorInfoView()
            NewsContentView()
                .padding(.horizontal, 10)
            replayListView
        }
        .navigationBarTitle(Text("话题"), displayMode: .inline)
        .updatable(refresh: {},
                   loadMore: { return true}
        )
        
    }
    
    private var replayListView: some View {
        ForEach( 0...20, id: \.self) { index in
            ReplyItemView()
        }
    }
}

struct NewsDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewsDetailPage()
        }
    }
}
