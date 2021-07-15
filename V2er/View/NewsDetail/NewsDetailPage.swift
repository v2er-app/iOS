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
        VStack {
            LazyVStack(spacing: 0) {
                AuthorInfoView()
                NewsContentView()
                    .padding(.horizontal, 10)
                Image("demo")
                replayListView
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
            .overlay {
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
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            navBar
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
    }
    
    private var navBar: some View  {
        NavbarHostView(paddingH: 0) {
            HStack(alignment: .center, spacing: 8) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .padding(.leading, 12)
                        .padding(.trailing, 8)
                        .padding(.vertical, 10)
                        .foregroundColor(.black)
                }
                Group {
                    NavigationLink(destination: UserDetailPage()) {
                        Image(systemName: "wave.3.backward.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36)
                            .fixedSize()
                            .foregroundColor(.black)
                    }
                    VStack(alignment: .leading) {
                        Text("话题")
                            .font(.headline)
                        Text("Subtitle3eeeeeeeeeeeeeeeee3333333333")
                            .font(.subheadline)
                    }
                    .lineLimit(1)
                    .padding(.trailing, 8)
                }
                .opacity(hideTitleViews ? 0.0 : 1.0)
            }
            .padding(.vertical, 5)
            .padding(.trailing, 6)
            .overlay {
                Text("话题")
                    .font(.headline)
                    .opacity(hideTitleViews ? 1.0 : 0.0)
            }
            .greedyWidth()
        }
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
