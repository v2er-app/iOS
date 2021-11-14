//
//  TestView.swift
//  V2er
//
//  Created by ghui on 2021/10/28.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        ScrollView {
            VStack {
                SectionItemView("Show Toast").onTapGesture {
                    Toast.show("网络错误")
                }
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
