//
//  SettingsPage.swift
//  SettingsPage
//
//  Created by Seth on 2021/8/3.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import SafariServices

// Wrapper to make URL Identifiable for sheet presentation
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsPage: View {
  @Environment(\.dismiss) var dismiss
  @State private var showingAlert = false
  @State var logingOut: Bool = false
  @State private var safariURL: IdentifiableURL?

  var body: some View {
    formView
      .navBar("设置")
      .sheet(item: $safariURL) { item in
        SafariView(url: item.url)
      }
  }

  @ViewBuilder
  private var formView: some View {
    ScrollView {
      VStack(spacing: 0) {
        SectionItemView("外观设置", showDivider: false)
          .padding(.top, 8)
          .to { AppearanceSettingView() }

        SectionItemView("通用设置")
          .to { OtherSettingsView() }

        Button {
          if let url = URL(string: "https://github.com/v2er-app/iOS/issues") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          SectionItemView("问题反馈")
            .padding(.top, 8)
        }

        Button {
          if let url = URL(string: "https://www.v2ex.com/help") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          SectionItemView("V2EX帮助")
        }

        Button {
          if let url = URL(string: "https://github.com/v2er-app") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          SectionItemView("源码开放")
        }

        Button {
          if let url = URL(string: "https://v2er.app") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          SectionView("关于") {
            HStack {
              Text("版本1.0.0")
                .font(.footnote)
                .foregroundColor(Color.tintColor)
              Image(systemName: "chevron.right")
                .font(.body.weight(.regular))
                .foregroundColor(.secondaryText)
                .padding(.trailing, 16)
            }
          }
        }
        
        Button {
          //                  "https://github.com/v2er-app".openURL()
          showingAlert = true
        } label: {
          SectionItemView("账号注销")
            .padding(.top, 8)
        }
        
        //                Button {
        //                    // go to app store
        //                } label: {
        //                    SectionItemView("给V2er评分", showDivider: false)
        //                }
        //                .hide()
        
        Button {
          // go to app store
          withAnimation {
            logingOut = true
          }
        } label: {
          SectionItemView("退出登录", showDivider: false)
            .foregroundColor(.red)
        }
        .confirmationDialog(
          "登出吗?",
          isPresented: $logingOut,
          titleVisibility: .visible
        ) {
          Button("确定", role: .destructive) {
            withAnimation {
              logingOut = false
            }
            AccountState.deleteAccount()
            Toast.show("已登出")
            dismiss()
          }
        }
        
      }
      .alert(String("账号注销"), isPresented: $showingAlert) {
        Button("确定", role: .cancel) { }
      } message: {
        Text("V2er作为V2EX的第三方客户端无法提供账号注销功能，若你想注销账号可访问V2EX官方网站: https://www.v2ex.com/help, 或联系V2EX团队: support@v2ex.com")
      }
    }
  }
}


struct SettingsPage_Previews: PreviewProvider {
  static var previews: some View {
    SettingsPage()
  }
}
