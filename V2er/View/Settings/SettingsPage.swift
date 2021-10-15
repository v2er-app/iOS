//
//  SettingsPage.swift
//  SettingsPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct SettingsPage: View {

    var body: some View {
        formView
            .navBar("设置")
    }

    @ViewBuilder
    private var formView: some View {
        ScrollView {
            VStack(spacing: 0) {
                SectionItemView("外观设置").to { AppearanceSettingView() }
                SectionItemView("浏览设置", showDivider: false)
                    .to { BrowseSettingView() }
                SectionItemView("其他设置", showDivider: false)
                    .padding(.top, 8)
                    .to { OtherSettingsView() }
                SectionItemView("帮助与反馈")
                    .padding(.top, 8)
                    .to { FeedbackHelperView() }
                SectionView("关于") {
                    HStack {
                        Text("版本1.0.0")
                            .font(.footnote)
                            .foregroundColor(Color.tintColor)
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.regular))
                            .foregroundColor(.gray)
                            .padding(.trailing, 16)
                    }
                }
                .to { AboutView() }
                Button {
                    // go to app store
                } label: {
                    SectionItemView("给V2er评分", showDivider: false)
                }

                Button {
                    // go to app store
                } label: {
                    SectionItemView("退出登录", showDivider: false)
                        .padding(.top, 8)
                }

            }
        }
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
