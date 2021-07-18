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
                    Button(action: { replyIsFocused = false}) {
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
            .padding(.bottom, isKeyboardVisiable ? 0 : safeAreaInsets().bottom * 0.9)
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .background(Color.white)
        }
    }
    
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
    
    private var navBar: some View  {
        NavbarHostView(paddingH: 0) {
            HStack(alignment: .center, spacing: 8) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.regular))
                        .padding(.leading, 12)
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
            .padding(.trailing, 5)
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
