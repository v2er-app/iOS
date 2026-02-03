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
        List {
            Section {
                ForEach(apps, id: \.id) { app in
                    AppItemView(app: app)
                }
            } footer: {
                Text("感谢你的支持")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("更多应用")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Dismiss badge when user views this page
            manager.dismissBadge()
        }
    }
}

// MARK: - App Item View

private struct AppItemView: View {
    let app: OtherApp

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
                        .foregroundStyle(.primary)
                    Text(app.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Download Button
                Text("获取")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.tintColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct OtherAppsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OtherAppsView()
        }
    }
}
