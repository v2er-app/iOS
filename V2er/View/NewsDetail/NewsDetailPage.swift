//
//  NewsDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsDetailPage: View, KeyboardReadable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var hideTitleViews = true
    @State var replyContent = ""
    @State var isKeyboardVisiable = false
    @FocusState private var replyIsFocused: Bool
    
    private var hasReplyContent: Bool {
        !replyContent.isEmpty
    }
    
    var body: some View {
        VStack (spacing: 0) {
            LazyVStack(spacing: 0) {
                AuthorInfoView()
                NewsContentView()
                    .padding(.horizontal, 10)
                actionItems
                replayListView
                    .padding(.top, 8)
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
                replyIsFocused = false
            }
            
            replyBar
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            navBar
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
        .onTapGesture {
            replyIsFocused = false
        }
    }
    
    @ViewBuilder
    private var actionItems: some View {
        VStack {
            HStack(spacing: 16) {
                // 收藏，忽略，感谢，举报, up, down
                
                Button("收藏") {
                    
                }
                Button("感谢") {
                    
                }
                
                Button("忽略") {
                    
                }
                
                Button("举报") {
                    
                }
                
                Spacer()
            }
            .padding(.top, 4)
            .padding(.horizontal, 16)
            .foregroundColor(.black)
            .font(.body)
            Divider()
        }
    }
    
    
    private var replyBar: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    MultilineTextField("发表回复", text: $replyContent)
                        .onReceive(keyboardPublisher) { isKeyboardVisiable in
                            self.isKeyboardVisiable = isKeyboardVisiable
                        }
                        .focused($replyIsFocused)
                        .debug()
                    
                    
                    
                    Button(action: {
                        // Do submit
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title.weight(.regular))
                            .foregroundColor(Color.bodyText.opacity(hasReplyContent ? 1.0 : 0.6))
                            .padding(.trailing, 6)
                            .padding(.vertical, 3)
                    }
                    .disabled(!hasReplyContent)
                    .debug()
                }
                .background(Color.lightGray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                
                if isKeyboardVisiable {
                    actionBar
                        .transition(.opacity)
                        .debug()
                }
            }
            .padding(.bottom, isKeyboardVisiable ? 0 : topSafeAreaInset().bottom * 0.9)
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private var actionBar: some View {
        HStack (spacing: 10) {
            Image(systemName: "photo.on.rectangle")
                .font(.title2.weight(.regular))
            Image(systemName: "face.smiling")
                .font(.title2.weight(.regular))
            Spacer()
        }
        .greedyWidth()
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var navBar: some View  {
        NavbarHostView(paddingH: 0) {
            HStack(alignment: .center, spacing: 4) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.regular))
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                        .foregroundColor(.tintColor)
                }
                .debug()
                Group {
                    NavigationLink(destination: UserDetailPage()) {
                        Image(systemName: "wave.3.backward.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32)
                            .fixedSize()
                            .foregroundColor(.tintColor)
                    }
                    VStack(alignment: .leading) {
                        Text("话题")
                            .font(.headline)
                        Text("Subtitle3eeeeeeeeeeeeeeeee3333333333")
                            .font(.subheadline)
                    }
                    .lineLimit(1)
                }
                .opacity(hideTitleViews ? 0.0 : 1.0)
                
                Button {
                    // Show more actions
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                    //                        .rotationEffect(.degrees(90))
                        .font(.title3.weight(.regular))
                        .foregroundColor(.tintColor)
                        .debug()
                }
            }
            .padding(.vertical, 5)
            .padding(.trailing, 5)
            .overlay {
                Text("话题")
                    .font(.headline)
                    .opacity(hideTitleViews ? 1.0 : 0.0)
            }
            .greedyWidth()
        }
        .visualBlur()
    }
    
    @ViewBuilder
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
