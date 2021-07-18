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
    @Binding var progress: CGFloat
    @Binding var isRefreshing: Bool
    
    var offset: CGFloat {
        return isRefreshing ? 0 : -height
    }
    
    init(threshold: CGFloat, progress: Binding<CGFloat>, isRefreshing: Binding<Bool>) {
        self.height = threshold
        self._progress = progress
        self._isRefreshing = isRefreshing
    }
    
    var body: some View {
        ZStack {
            Group {
                if progress == 1 || isRefreshing {
                    ActivityIndicator()
                } else {
                    Image(systemName: "arrow.down")
                        .font(.title2.weight(.regular))
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .fixedSize()
                }
            }
            VStack {
                Spacer()
                Divider()
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
        HeadIndicatorView(threshold: 80, progress: $progress,
                          isRefreshing: $isRefreshing)
        //            .border(.red)
    }
}
