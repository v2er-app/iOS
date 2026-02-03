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
  @ObservedObject private var otherAppsManager = OtherAppsManager.shared

  // Get version and build number from Bundle
  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "版本v\(version)(\(build))"
  }

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
        Button {
          if let url = URL(string: "https://v2er.app/help") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          HStack {
            Image(systemName: "")
              .padding(.leading, 15)
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text("问题反馈")
                Text("唯一渠道: https://v2er.app/help")
                  .font(.footnote)
                  .foregroundColor(.secondaryText)
              }
              Spacer()
              Image(systemName: "chevron.right")
                .font(.body.weight(.regular))
                .foregroundColor(.secondaryText)
                .padding(.trailing, 30)
            }
            .padding(.vertical, 17)
          }
          .background(Color.itemBackground)
          .padding(.top, 8)
        }

        SectionItemView("外观设置")
          .to { AppearanceSettingView() }

        SectionItemView("通用设置")
          .to { OtherSettingsView() }

        Button {
          if let url = URL(string: "https://www.v2ex.com/help") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          SectionItemView("V2EX帮助")
            .padding(.top, 8)
        }

        Button {
          if let url = URL(string: "https://github.com/v2er-app") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          SectionItemView("源码开放")
        }

        SectionItemView("致谢")
          .to { CreditsPage() }

        // Other Apps Section with badge
        OtherAppsSectionView(showBadge: otherAppsManager.showOtherAppsBadge)
          .to { OtherAppsView() }

        Button {
          if let url = URL(string: "https://v2er.app") {
            safariURL = IdentifiableURL(url: url)
          }
        } label: {
          SectionView("关于") {
            HStack {
              Text(appVersion)
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


// MARK: - Other Apps Section View

private struct OtherAppsSectionView: View {
    let showBadge: Bool

    var body: some View {
        HStack {
            Image(systemName: "square.grid.2x2")
                .font(.body.weight(.semibold))
                .padding(.leading, 15)
                .padding(.trailing, 5)
                .foregroundColor(.tintColor)
            HStack {
                Text("更多应用")
                if showBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.regular))
                    .foregroundColor(.secondaryText)
                    .padding(.trailing, 15)
            }
            .padding(.vertical, 17)
            .divider(0.8)
        }
        .background(Color.itemBackground)
    }
}

struct SettingsPage_Previews: PreviewProvider {
  static var previews: some View {
    SettingsPage()
  }
}
