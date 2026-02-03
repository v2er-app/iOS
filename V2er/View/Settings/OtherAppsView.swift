//
//  OtherAppsView.swift
//  V2er
//
//  Created on 2026/2/3.
//  Copyright © 2026 lessmore.io. All rights reserved.
//

import SwiftUI

struct OtherAppsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = OtherAppsManager.shared

    private let apps = OtherAppsManager.otherApps

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<apps.count, id: \.self) { index in
                    AppItemView(
                        app: apps[index],
                        showDivider: index < apps.count - 1
                    )
                }
            }
            .background(Color.itemBackground)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Text("感谢你的支持")
                .font(.footnote)
                .foregroundColor(.secondaryText)
                .padding(.top, 24)
        }
        .background(Color.bgColor)
        .navBar("更多应用")
        .onAppear {
            // Dismiss badge when user views this page
            manager.dismissBadge()
        }
    }
}

// MARK: - App Item View

private struct AppItemView: View {
    let app: OtherApp
    let showDivider: Bool

    var body: some View {
        Button {
            if let url = app.appStoreUrl {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                // App Icon
                Image(app.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                    )

                // App Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    Text(app.description)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                }

                Spacer()

                // Download Button
                Text("获取")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.tintColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.tintColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.itemBackground)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if showDivider {
                Divider()
                    .padding(.leading, 84)
            }
        }
    }
}

// MARK: - Preview

struct OtherAppsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherAppsView()
    }
}
