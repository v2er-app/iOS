//
//  HeadView.swift
//  V2er
//
//  Created by Seth on 2021/6/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct HeadIndicatorView: View {
    let height: CGFloat
    var scrollY: CGFloat
    @Binding var progress: CGFloat
    @Binding var isRefreshing: Bool
    var onlineStats: OnlineStatsInfo?

    @State private var animatedOnlineCount: Int = 0

    var offset: CGFloat {
        return isRefreshing ? (0 - scrollY) : -height
    }

    init(threshold: CGFloat, progress: Binding<CGFloat>, scrollY: CGFloat, isRefreshing: Binding<Bool>, onlineStats: OnlineStatsInfo? = nil) {
        self.height = threshold
        self.scrollY = scrollY
        self._progress = progress
        self._isRefreshing = isRefreshing
        self.onlineStats = onlineStats
        if let stats = onlineStats {
            self._animatedOnlineCount = State(initialValue: stats.onlineCount)
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            if progress == 1 || isRefreshing {
                ActivityIndicator()
            } else {
                Image(systemName: "arrow.down")
                    .font(.title2.weight(.regular))
            }

            if let stats = onlineStats, stats.isValid() {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.hex(0x52bf1c))
                        .frame(width: 6, height: 6)

                    if #available(iOS 16.0, *) {
                        Text("\(animatedOnlineCount) 人在线")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                            .contentTransition(.numericText())
                    } else {
                        Text("\(animatedOnlineCount) 人在线")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                .onChange(of: stats.onlineCount) { newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animatedOnlineCount = newValue
                    }
                }
            }
        }
        .frame(height: height)
        .offset(y: offset)

    }
}

struct HeadView_Previews: PreviewProvider {
    @State static var progress: CGFloat = 0.1
    @State static var isRefreshing = false
    
    static var previews: some View {
        HeadIndicatorView(threshold: 80, progress: $progress, scrollY: 0,
                          isRefreshing: $isRefreshing)
        //            .border(.red)
    }
}
