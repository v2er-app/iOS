//
//  TestView.swift
//  V2er
//
//  Created by ghui on 2021/10/28.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct TestView: View {
    @State var showToast: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                SectionItemView("Show toast")
                    .onTapGesture {
                        Toast.show("网络加载错误")
                    }
            }
        }
        .navigatable()
        .toast(isPresented: $showToast) {
            Label("showToast", systemImage: "star")
                .padding(.horizontal, 26)
                .padding(.vertical, 12)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
