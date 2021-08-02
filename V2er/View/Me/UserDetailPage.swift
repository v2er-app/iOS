//
//  UserDetailPage.swift
//  UserDetailPage
//
//  Created by Seth on 2021/7/28.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct UserDetailPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var statusBarConfigurator = StatusBarConfigurator()
    
    @State private var scrollY: CGFloat = 0.0
    private let heightOfNodeImage = 60.0
    @State private var bannerViewHeight: CGFloat = 0
    @State private var tabIndex: Int = 0
    
    private var shouldHideNavbar: Bool {
        let hideNavbar =  scrollY > -heightOfNodeImage * 1.0
        statusBarConfigurator.statusBarStyle = hideNavbar ? .lightContent : .darkContent
        return hideNavbar
    }
    
    private var foreGroundColor: Color {
        shouldHideNavbar ? .white.opacity(0.9) : .tintColor
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            navBar
                .zIndex(1)
            VStack(spacing: 0) {
                topBannerView
                    .readSize {
                        bannerViewHeight = $0.height
                    }
                HStack(spacing: 4) {
                    Text("主题")
                        .font(.body.weight(tabIndex == 0 ? .heavy : .regular))
                        .padding(.bottom, 4)
                        .background {
                            VStack(spacing: 0) {
                                Spacer()
                                Color.tintColor.frame(height: 3)
                            }
                            .opacity(self.tabIndex == 0 ? 1.0 : 0.0)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.tabIndex = 0
                            }
                        }
                    Text("回复")
                        .font(.body.weight(tabIndex == 1 ? .heavy : .regular))
                        .padding(.bottom, 4)
                        .background {
                            VStack(spacing: 0) {
                                Spacer()
                                Color.tintColor.frame(height: 3)
                            }
                            .opacity(self.tabIndex == 1 ? 1.0 : 0.0)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.tabIndex = 1
                            }
                        }
                    Spacer()
                }
                .padding(.leading, 10)
                .background(.white)
                
                topicDetailView
                //                TabView(selection: $tabIndex) {
                //                    topicDetailView
                //                        .tag(0)
                //                    Text("World")
                //                        .tag(1)
                //                }
                //                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                //                .debug()
            }
            .loadMore {
                return true
            } onScroll: {
                self.scrollY = $0
            }
            .background {
                VStack(spacing: 0) {
                    Image("avar")
                        .resizable()
                        .blur(radius: 80, opaque: true)
                        .overlay(Color.black.opacity(withAnimation {shouldHideNavbar ? 0.3 : 0.1}))
                        .frame(height: bannerViewHeight + max(scrollY, 0))
                    Spacer()
                }
            }
        }
        .prepareStatusBarConfigurator(statusBarConfigurator)
        .buttonStyle(.plain)
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
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
                }
                .forceClickable()
                
                Group {
                    AvatarView(size: 36)
                        .overlay {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                                .offset(x: 9, y: 36/2 - 2)
                        }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ghui")
                            .font(.headline)
                        Text("V2EX第269646 号会员，加入于 2017-11-23 16:28:09 +08:00")
                            .font(.subheadline)
                        //                        Circle().fill(.green).frame(width: 8, height: 8)
                    }
                    .lineLimit(1)
                }
                .opacity(shouldHideNavbar ? 0.0 : 1.0)
                
                Spacer()
                
                Button {
                    // Star the node
                } label: {
                    Image(systemName: "heart")
                        .padding(8)
                        .font(.title3.weight(.regular))
                }
                .opacity(shouldHideNavbar ? 0.0 : 1.0)
                .forceClickable()
                
                Button {
                    // block user
                } label: {
                    Image(systemName: "eye.slash")
                        .padding(8)
                        .font(.body.weight(.regular))
                }
                .forceClickable()
            }
            .padding(.vertical, 5)
        }
        .hideDivider(hide: shouldHideNavbar)
        .foregroundColor(foreGroundColor)
        .visualBlur(alpha: shouldHideNavbar ? 0.0 : 1.0)
    }
    
    
    @ViewBuilder
    private var topBannerView: some View {
        VStack (spacing: 14) {
            Color.clear.frame(height: topSafeAreaInset().top)
            AvatarView(size: heightOfNodeImage)
            HStack(alignment: .center,spacing: 4) {
                Circle().fill(.green).frame(width: 8, height: 8)
                Text("ghui")
                    .font(.headline.weight(.semibold))
            }
            Button {
                // do star
            } label: {
                Text("关注")
                    .font(.callout)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 2)
                    .roundedEdge(radius: 99, borderWidth: 1, color: foreGroundColor)
            }
            Text("V2EX 第 269646 号会员，加入于 2017-11-23 16:28:09 +08:00")
                .font(.callout)
            Color.white
                .frame(height: 20)
                .cornerRadius(10, corners: [.topLeft, .topRight])
        }
        .foregroundColor(foreGroundColor)
        .foregroundColor(.bodyText)
        .padding(.top, 8)
    }
    
    
    //    @ViewBuilder
    //    private var detailTabListView: some View {
    //        VStack(spacing: 0) {
    //            // TabTitleViews
    //
    //            // Tab Content views
    //
    //        }
    //        .greedyFrame()
    //    }
    
    @ViewBuilder
    private var topicDetailView: some View {
        VStack(spacing: 0) {
            ForEach( 0...20, id: \.self) { i in
                NavigationLink(destination: NewsDetailPage()) {
                    NewsItemView()
                }
            }
        }
        .background(.white)
    }
}

struct UserDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailPage()
    }
}
