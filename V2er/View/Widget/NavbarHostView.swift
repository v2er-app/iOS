//
//  NavHostView.swift
//  V2er
//
//  Created by Seth on 2021/7/15.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NavbarHostView<Content: View>: View {
    let content: Content
    let paddingH: CGFloat
    let hideDivider: Bool
    
    init(paddingH: CGFloat = 2, hideDivider: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.paddingH = paddingH
        self.hideDivider = hideDivider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topSafeAreaInset().top)
            HStack(alignment: .center, spacing: 0) {
                self.content
            }
            .greedyWidth()
            Divider()
                .opacity(hideDivider ? 0.0 : 1.0)
        }
        .greedyWidth()
        .padding(.horizontal, self.paddingH)
        .frame(minHeight: 50)
        .forceClickable()
    }
}

struct NavbarTitleView<TitleView: View>: View {
    let titleView: TitleView
    let onBackPressed: (()->Void)?

    init(@ViewBuilder titleView: () -> TitleView,
         onBackPressed: (()->Void)? = nil) {
        self.titleView = titleView()
        self.onBackPressed = onBackPressed
    }
    var body: some View {
        NavbarView {
            titleView
        } contentView: {

        } onBackPressed: {
            onBackPressed?()
        }
    }
}

struct NavbarView<TitleView, ContentView>: View where TitleView: View, ContentView: View {
    @Environment(\.dismiss) var dismiss
    let titleView: TitleView
    let onBackPressed: (()->Void)?
    let contentView: ContentView

    init(@ViewBuilder titleView: () -> TitleView,
         @ViewBuilder contentView: () -> ContentView,
         onBackPressed: (()->Void)? = nil) {
        self.titleView = titleView()
        self.contentView = contentView()
        self.onBackPressed = onBackPressed
    }

    var body: some View {
        NavbarHostView(paddingH: 0, hideDivider: false) {
            HStack(alignment: .center, spacing: 4) {
                Button {
                    dismiss()
                    onBackPressed?()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.regular))
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                        .foregroundColor(.tintColor)
                }
                Spacer()
                contentView
            }
            .greedyWidth()
            .overlay {
                HStack(alignment: .center) {
                    titleView
                }
            }
        }
        .visualBlur()
        .navigationBarHidden(true)
        .ignoresSafeArea(.container)
    }
}

extension View {
    func navBar(_ title: String) -> some View {
        return self.modifier(NavBarModifier(title: title))
    }
}

struct NavBarModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss
    let title: String

    func body(content: Content) -> some View {
        NavigationView {
            content
                .safeAreaInset(edge: .top, spacing: 0) {
                    NavbarTitleView {
                        Text(title)
                            .font(.headline)
                    } onBackPressed: {
                        dismiss()
                    }
                }
                .background(Color.bgColor)
                .navigationBarHidden(true)
                .ignoresSafeArea(.all)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all)
    }
}

struct NavHostView_Previews: PreviewProvider {
    static var previews: some View {
        Color.clear
            .navBar("Title")
    }
}
