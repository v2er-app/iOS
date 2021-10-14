//
//  BrowseSettingView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct BrowseSettingView: View {
    @State private var isOn: Bool = false

    var body: some View {
        formView
            .navBar("浏览设置")
    }

    @ViewBuilder
    private var formView: some View {
        ScrollView {
            SectionView("逆序浏览") {
                Toggle(.empty, isOn: $isOn)
            }
        }
    }
}

struct BrowseSettingView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseSettingView()
    }
}
