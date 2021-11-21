//
//  AppearanceSettingView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct AppearanceSettingView: View {
    var body: some View {
        formView
            .navBar("外观设置")
    }

    @ViewBuilder
    private var formView: some View {
        ScrollView {
            SectionItemView("字体大小")
//                .to {}
        }
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingView()
    }
}
