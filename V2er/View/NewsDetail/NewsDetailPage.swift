//
//  NewsDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import PureSwiftUI

struct NewsDetailPage: View {
    var body: some View {
        VStack {
            Text("DetailPage")
            Color.blue.frame(width: 100, height: 100)
        }
        .debug()
        .updatable(refresh: {},
                   loadMore: { return true}
        )
        .navigationBarTitle(Text("话题"), displayMode: .inline)
    }
}

struct NewsDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewsDetailPage()
        }
    }
}
