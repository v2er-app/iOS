//
//  Home.swift
//  V2er
//
//  Created by Seth on 2020/5/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
import BxRefreshableScrollView

struct HomePage: View {
    @State var selectedId = TabId.feed
    @State var loading = false;
    @State var showMoreData = true;
    
    @State private var users : [User] = [User("1"), User("2"),User("3"), User("4"), User("5"), User("6"), User("7"), User("8"), User("9"), User("10"),
                                         User("1"), User("2"),User("3"), User("4"), User("5"), User("6"), User("7"), User("8"), User("9"), User("10"),
                                         User("1"), User("2"),User("3"), User("4"), User("5"), User("6"), User("7"), User("8"), User("9"), User("10")]
    
    var body: some View {
        //        List(users) { user in
        //            VStack {
        //                Text(user.id)
        //                Spacer()
        //            }
        //        }
        //        .ignoresSafeArea()
        //        ScrollView (.vertical, showsIndicators: false) {
        //            ForEach( 0...60, id: \.self) { i in
        //                Text(" LineLineLineLineLineLineLineLineLine Number \(i)   ")
        //                    .background(i % 5 == 0 ? Color.blue : Color.clear)
        //            }
        //        }
        //        .refreshable {
        //            print("start to refresh...")
        //        }
        
        RefreshableScrollView(
            height: 70,
            refreshing: self.$loading,
            bottomRefreshable: true,
            showNoMoreData: $showMoreData,
            showBottomLoading: $showMoreData
        ) {
            VStack {
                ForEach( 0...60, id: \.self) { i in
                    Text(" LineLineLineLineLineLineLineLineLine Number \(i)   ")
                        .background(i % 5 == 0 ? Color.blue : Color.clear)
                }
            }
        }
        
    }
    
    
    private struct User: Identifiable {
        var id: String
        
        public init(_ id: String) {
            self.id = id;
        }
    }
    
    struct HomePage_Previews: PreviewProvider {
        static var previews: some View {
            HomePage()
        }
    }
}
