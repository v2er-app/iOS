//
//  RefreshableView.swift
//  V2er
//
//  Created by Seth on 2021/6/24.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI


/**
 * 1. Could custome HeadView (custome in the future, e.g. state in progress, state refreshing, state finished
 * 2. Could custome LoadmoreView (same as HeadView)
 * 3. Two actions:
 *  1. onRefresh
 *  2. onLoadMoreStart
 */

struct RefreshableView<Content: View>: View {
    let onRefresh: () async-> Void
    let content: Content
    @State var scrollY: CGFloat = 0
    @State var lastScrollY: CGFloat = 0
    @State var isRefreshing: Bool = false
    @State var progress: CGFloat = 0
    let threshold: CGFloat = 50
    
    fileprivate init(onRefresh: @escaping () async -> Void = {},
                     @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                AncorView()
                HeadIndicatorView(threshold: threshold, progress: $progress, isRefreshing: $isRefreshing).zIndex(9)
                content
                    .alignmentGuide(.top, computeValue: { d in (self.isRefreshing ? -self.threshold : 0.0) })
                // loadMoreView
            }
        }
        .coordinateSpace(name: "RefreshableView")
        .onPreferenceChange(ScrollOffsetKey.self, perform: onScroll)
        
    }
    
    private func onScroll(point: CGPoint) {
        scrollY = point.y
        print("scrollY: \(scrollY), lastScrollY: \(lastScrollY), isRefreshing: \(isRefreshing)")
        progress = min(1, max(scrollY / threshold, 0))
        if !isRefreshing && scrollY <= threshold && lastScrollY > threshold {
            isRefreshing = true
            async {
                await onRefresh()
                isRefreshing = false
            }
        }
        lastScrollY = scrollY
    }
    
}

private struct AncorView: View {
    var body: some View {
        GeometryReader{ geometry in
            Color.clear
                .preference(
                    key: ScrollOffsetKey.self,
                    value: geometry.frame(in: .named("RefreshableView")).origin
                )
        }
        .frame(height: 0)
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        // do nothing here, value is what we need.
    }
}


extension View {
    public func onRefresh(action: @escaping () async -> Void) -> some View {
        self.modifier(RefreshableModifier(onRefresh: action))
    }
}

struct RefreshableModifier: ViewModifier {
    let onRefresh: () async -> Void
    
    func body(content: Content) -> some View {
        RefreshableView(onRefresh: onRefresh) {
            content
        }
    }
    
}


struct RefreshableView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVStack {
            ForEach( 0...60, id: \.self) { i in
                Text(" LineLineLineLineLineLineLineLineLine Number \(i)   ")
                    .background(i % 5 == 0 ? Color.blue : Color.clear)
            }
        }
        .onRefresh {
            print("onRefresh...")
        }
    }
}
