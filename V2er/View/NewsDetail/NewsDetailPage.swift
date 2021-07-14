//
//  NewsDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsDetailPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var hideTitleViews = true
    @State var replyContent = ""
    
    var body: some View {
        ZStack {
            LazyVStack(spacing: 0) {
                AuthorInfoView()
                NewsContentView()
                    .padding(.horizontal, 10)
                Image("demo")
                replayListView
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ZStack {
                        HStack(alignment: .center) {
                            Button {
                                self.presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(.black)
                            }
                            Group {
                                NavigationLink(destination: UserDetailPage()) {
                                    Image(systemName: "wave.3.backward.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                VStack(alignment: .leading) {
                                    Text("话题")
                                        .font(.headline)
                                    Text("Subtitle3eeeeeeeeeeeeeeeee3333333333")
                                        .font(.subheadline)
                                }
                                .padding(.trailing, 8)
                            }
                            .opacity(hideTitleViews ? 0.0 : 1.0)
                        }
                        Text("话题")
                            .font(.headline)
                            .opacity(hideTitleViews ? 1.0 : 0.0)
                    }
                }
            }
            .updatable {
                // do refresh...
            } loadMore: {
                return true
            } onScroll: { scrollY in
                print("scrollY: \(scrollY)")
                withAnimation {
                    hideTitleViews = !(scrollY <= -100)
                }
            }
            
            VStack(spacing: 0) {
                Spacer()
                Divider()
                Group {
                    TextField("发表回复", text: $replyContent)
//                    TextEditor(text: $replyContent)
                        .submitLabel(.send)
                        .textFieldStyle(OvalTextFieldStyle())
                }
                .padding(.bottom, safeAreaInsets().bottom)
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .background(Color.white)
            }
        }
        .ignoresSafeArea(.container)
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
