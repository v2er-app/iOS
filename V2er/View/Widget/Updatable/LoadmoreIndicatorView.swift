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
    @Binding var noMoreData: Bool
    
    
    init(isLoading: Binding<Bool>, noMoreData: Binding<Bool>) {
        self._isLoading = isLoading
        self._noMoreData = noMoreData
    }
    
    var body: some View {
        Group {
            if noMoreData {
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
    @State static var noMoreData = true
    
    static var previews: some View {
        LoadmoreIndicatorView(isLoading: $isloading, noMoreData: $noMoreData)
    }
}
