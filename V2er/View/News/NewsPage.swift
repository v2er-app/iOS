//
//  Home.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsPage: View {
    @Binding var selecedTab: TabId
    
    var body: some View {
        contentView
            .opacity(selecedTab == .feed ? 1.0 : 0.0)
    }
}

@ViewBuilder
private var contentView: some View {
    LazyVStack(spacing: 0) {
        ForEach( 0...20, id: \.self) { i in
            NavigationLink(destination: NewsDetailPage()) {
                NewsItemView()
            }
        }
    }
    .updatable {
        print("onRefresh...")
        let result = await fetchData()
        print("onRefresh ended...")
    } loadMore: {
        print("onLoadMore...")
        return true
    } onScroll: { offset in
//        print("onScroll.Y: \(offset)")
    }
}


private func fetchData() async -> [String] {
    await withCheckedContinuation { continuation in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let persons = [
                "new Person 1",
                "new Person 2",
                "new Person 3",
                "new Person 4"
            ]
            continuation.resume(returning: persons)
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    @State static var selected = TabId.feed
    
    static var previews: some View {
        NewsPage(selecedTab: $selected)
    }
}
