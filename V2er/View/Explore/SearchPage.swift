//
//  SearchPage.swift
//  SearchPage
//
//  Created by Seth on 2021/7/18.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct SearchPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var searchText: String = ""
    @FocusState private var editIsFocused: Bool
    
    var body: some View {
        LazyVStack (alignment: .leading ,spacing: 0) {
            ForEach( 0...20, id: \.self) { i in
                NavigationLink(destination: FeedDetailPage()) {
                    SearchResultItemView()
                }
            }
        }
        .navigationBarHidden(true)
        .buttonStyle(.plain)
        .updatable(
            loadMore: {
            })
        .safeAreaInset(edge: .top, spacing: 0) {
            searchView
        }
        .ignoresSafeArea(.container)
        .background(Color.lightGray)
    }
    
    private var searchView: some View {
        HStack(spacing: 0) {
            searchBar
            Button("取消") {
                // Cancel Search
                if editIsFocused {
                    editIsFocused = false
                } else {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .font(.body)
            .foregroundColor(.tintColor)
        }
        .padding(.top, topSafeAreaInset().top)
        .padding(.bottom, 10)
        .padding(.trailing, 10)
        .background(Color.gray.opacity(0.1))
        .background(VEBlur())
        
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Type to Search ...", text: $searchText)
                .padding(7)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .focused($editIsFocused)
        }
    }
    
}

fileprivate struct SearchResultItemView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Android开源项目汇总")
                    .font(.callout)
                Divider()
                    .padding(0)
                Text("仅支持4.0以上版本。Android Design.目前只是preview版本，还不支持看大图，登陆，发布，回复")
                    .font(.subheadline)
            }
            .padding()
            .background(.white)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
//        .background(Color.lightGray)
    }
    
}


struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchPage()
    }
}
