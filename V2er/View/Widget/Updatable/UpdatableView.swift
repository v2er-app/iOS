//
//  UpdatableView.swift
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
struct UpdatableView<Content: View>: View {
    let onRefresh: RefreshAction
    let onLoadMore: LoadMoreAction
    let onScroll: ScrollAction?
    let content: Content
    @State var scrollY: CGFloat = 0
    @State var lastScrollY: CGFloat = 0
    @State var isRefreshing: Bool = false
    @State var progress: CGFloat = 0
    let threshold: CGFloat = 60
    @State var boundsDelta = 0.0
    @State var isLoadingMore: Bool = false
    var hasMoreData: Bool = true
    var autoRefresh: Bool
    let damper: Float = 1.2
    var scrollToTop: Bool = false
    @State var hapticed = false

    private var refreshable: Bool {
        return onRefresh != nil
    }
    
    private var loadMoreable: Bool {
        return onLoadMore != nil
    }
    
    fileprivate init(onRefresh: RefreshAction,
                     onLoadMore: LoadMoreAction,
                     onScroll: ScrollAction?,
                     autoRefresh: Bool,
                     hasMoreData: Bool,
                     scrollToTop: Bool,
                     @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
        self.onScroll = onScroll
        self.content = content()
        self.autoRefresh = autoRefresh
        self.hasMoreData = hasMoreData
        self.scrollToTop = scrollToTop
    }

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                ZStack(alignment: .top) {
                    AncorView()
                        .id(0)
                    ZStack {
                        VStack(spacing: 0) {
                            content
                                .anchorPreference(key: ContentBoundsKey.self, value: .bounds) { $0 }
                            if loadMoreable {
                                LoadmoreIndicatorView(isLoading: isLoadingMore, hasMoreData: hasMoreData)
                            }
                        }
                    }
                    .alignmentGuide(.top, computeValue: { d in (self.isRefreshing ? (-self.threshold + scrollY) : 0.0) })
                    if refreshable {
                        HeadIndicatorView(threshold: threshold, progress: $progress, scrollY: scrollY, isRefreshing: $isRefreshing)
                    }
                }
            }
            .onChange(of: scrollToTop) { scrollToTop in
                guard scrollToTop else { return }
                withAnimation {
                    reader.scrollTo(0, anchor: .top)
                }
            }
        }
        .overlay {
            if autoRefresh {
                ZStack {
                    Color.almostClear
                    ProgressView()
                        .scaleEffect(1.3)
                }
            }
        }
        .backgroundPreferenceValue(ContentBoundsKey.self) { pref in
            GeometryReader { geometry in
                Color.clear
                    .preference(key: FrameContentBoundsDeltaKey.self,
                                value: geometry[pref!].height - geometry.size.height)
            }
        }
        .onPreferenceChange(FrameContentBoundsDeltaKey.self) { delta in
            self.boundsDelta = delta
        }
        .coordinateSpace(name: AncorView.coordinateSpaceName)
        .onPreferenceChange(ScrollOffsetKey.self, perform: onScroll)
    }
    
    private func onScroll(point: CGPoint) {
        scrollY = point.y
        onScroll?(scrollY)
        //        log("scrollY: \(scrollY), lastScrollY: \(lastScrollY), isRefreshing: \(isRefreshing), boundsDelta:\(boundsDelta)")
        progress = min(1, max(scrollY / threshold, 0))

        if progress == 1 && scrollY > lastScrollY && !hapticed {
            hapticed = true
            hapticFeedback(.soft)
        }

        if refreshable && !isRefreshing
            && scrollY <= threshold
            && lastScrollY > threshold {
            isRefreshing = true
            hapticed = false
            Task {
                await onRefresh?()
                runInMain {
                    withAnimation {
                        isRefreshing = false
                    }
                }
            }
        }

        if loadMoreable
            && hasMoreData
            && boundsDelta >= 0
            && Int(scrollY) < Int(-boundsDelta)
            && !isLoadingMore {
            isLoadingMore = true
            Task {
                log("loadingMore...")
                await onLoadMore!()
                runInMain {
                    isLoadingMore = false
                }
            }
        }
        
        lastScrollY = scrollY
    }
    
}

private struct AncorView: View {
    static let coordinateSpaceName = "coordinateSpace.UpdatableView"

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(
                    key: ScrollOffsetKey.self,
                    value: geometry.frame(in: .named(Self.coordinateSpaceName)).origin
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

struct ContentBoundsKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?
    static var defaultValue: Value = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        // Try do nothing
        //        print("value: \(value)")
    }
}

struct FrameContentBoundsDeltaKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = 0.0
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        // Do nothing...
    }
}


extension View {
    public func updatable(autoRefresh: Bool = false,
                          hasMoreData: Bool = true,
                          _ scrollToTop: Bool = false,
                          refresh: RefreshAction = nil,
                          loadMore: LoadMoreAction = nil,
                          onScroll: ScrollAction? = nil) -> some View {
        self.modifier(UpdatableModifier(onRefresh: refresh, onLoadMore: loadMore, onScroll: onScroll, autoRefresh: autoRefresh, hasMoreData: hasMoreData, scrollToTop: scrollToTop))
    }
    
    public func loadMore(autoRefresh: Bool = false,
                         hasMoreData: Bool = true,
                         _ loadMore: LoadMoreAction = nil,
                         onScroll: ScrollAction? = nil) -> some View {
        self.updatable(autoRefresh: autoRefresh, hasMoreData: hasMoreData, refresh: nil, loadMore: loadMore, onScroll: onScroll)
    }
    
}

struct UpdatableModifier: ViewModifier {
    let onRefresh: RefreshAction
    let onLoadMore: LoadMoreAction
    let onScroll: ScrollAction?
    let autoRefresh: Bool
    let hasMoreData: Bool
    let scrollToTop: Bool
    
    func body(content: Content) -> some View {
        UpdatableView(onRefresh: onRefresh, onLoadMore: onLoadMore,
                      onScroll: onScroll, autoRefresh: autoRefresh, hasMoreData: hasMoreData, scrollToTop: scrollToTop) {
            content
        }
    }
}



//struct UpdatableView_Previews: PreviewProvider {
//    static var previews: some View {
//        LazyVStack {
//            ForEach( 0...60, id: \.self) { i in
//                Text(" LineLineLineLineLineLineLineLineLine Number \(i)   ")
//                    .background(i % 5 == 0 ? Color.blue : Color.clear)
//            }
//        }
//        .updatable(refresh: { print("refresh...")},
//                   loadMore: { print("loadMore..."); return true},
//                   onScroll: {print("onScroll\($0)")})
//    }
//}
