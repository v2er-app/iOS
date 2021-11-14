//
//  SearchPage.swift
//  SearchPage
//
//  Created by Seth on 2021/7/18.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct SearchPage: StateView {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var store: Store
    var bindingState: Binding<SearchState> {
        return $store.appState.searchState
    }
    @FocusState private var focused: Bool

    var body: some View {
        NavigationView {
            LazyVStack (alignment: .leading ,spacing: 0) {
                ForEach(state.model?.hits ?? []) { item in
                    NavigationLink(destination: FeedDetailPage(id: item.id)) {
                        SearchResultItemView(hint: item)
                    }
                }
            }
            .navigationBarHidden(true)
            .loadMore(state.updatable) {
                await run(action: SearchActions.LoadMoreStart())
            }
            .onChange(of: state.sortWay) { sort in
                dispatch(SearchActions.Start())
            }
            .safeAreaInset(edge: .top, spacing: 0) { searchView }
            .ignoresSafeArea(.container)
            .background(Color.bgColor)
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
    }


    @ViewBuilder
    private var searchView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("sov2ex", text: bindingState.keyword)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .focused($focused)
                        .submitLabel(.search)
                        .onSubmit { dispatch(SearchActions.Start()) }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                                self.focused = true
                            }
                        }
                }
                .padding(7)
                .padding(.horizontal, 8)
                .background(Color.itemBg.opacity(0.6))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.top, 5)
                Button("取消") {
                    // Cancel Search
                    if focused {
                        focused = false
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(.tintColor)
            }
            .padding(.top, topSafeAreaInset().top)
            .padding(.trailing, 10)
            sortPickerView
                .padding(10)
            Divider()
        }
        .visualBlur()
        .background(Color.gray.opacity(0.35))
    }

    @ViewBuilder
    private var sortPickerView: some View {
        Picker("Sort", selection: bindingState.sortWay) {
            Text("相关")
                .tag("sumup")
            Text("最新")
                .tag("created")
        }
        .font(.headline)
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

fileprivate struct SearchResultItemView: View {
    let hint: SearchState.Model.Hit
    var data: SearchState.Model.Hit.Source {
        hint.source
    }
    
    var body: some View {
        let padding: CGFloat = 16
        VStack(alignment: .leading) {
            Text(data.title)
                .fontWeight(.semibold)
                .greedyWidth(.leading)
                .lineLimit(2)
            Text(data.content)
                .lineLimit(5)
                .padding(.vertical, 5)
            Text("\(data.creator) 于 \(data.created) 发表, \(data.replyNum) 回复")
                .font(.footnote)
                .foregroundColor(Color.tintColor.opacity(0.8))
        }
        .foregroundColor(Color.bodyText)
        .greedyWidth()
        .padding(padding)
        .background(Color.itemBg)
        .padding(.bottom, 8)
    }
}


struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchPage()
            .environmentObject(Store.shared)
    }
}
