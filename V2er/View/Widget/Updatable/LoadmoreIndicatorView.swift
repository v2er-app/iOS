//
//  LoadmoreIndicatorView.swift
//  V2er
//
//  Created by Seth on 2021/7/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct LoadmoreIndicatorView: View {
    @Binding var isLoading: Bool
    @Binding var hasMoreData: Bool

    init(isLoading: Binding<Bool>, hasMoreData: Binding<Bool>) {
        self._isLoading = isLoading
        self._hasMoreData = hasMoreData
    }
    
    var body: some View {
        Group {
            if !hasMoreData {
                Text("No more data")
                    .font(.callout)
            } else if isLoading {
                ActivityIndicator()
            } else {
                // hide
            }
        }
        .padding()
    }
}

struct LoadmoreIndicatorView_Previews: PreviewProvider {
    @State static var isloading = true
    @State static var hasMoreData = true
    
    static var previews: some View {
        LoadmoreIndicatorView(isLoading: $isloading, hasMoreData: $hasMoreData)
    }
}
