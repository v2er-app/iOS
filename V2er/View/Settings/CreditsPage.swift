//
//  CreditsPage.swift
//  V2er
//
//  Created by Claude on 2024.
//  Copyright © 2024 lessmore.io. All rights reserved.
//

import SwiftUI
import SafariServices

struct CreditsPage: View {
    @State private var safariURL: IdentifiableURL?

    var body: some View {
        List {
            // MARK: - Search Engine Section
            Section {
                Button {
                    if let url = URL(string: "https://sov2ex.com") {
                        safariURL = IdentifiableURL(url: url)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("sov2ex.com")
                                .foregroundStyle(.primary)
                            Text("V2EX 搜索引擎")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("搜索")
            } footer: {
                Text("提供 V2EX 内容搜索功能")
            }

            // MARK: - Open Source Libraries Section
            Section {
                creditRow(
                    name: "Kingfisher",
                    description: "图片加载和缓存",
                    url: "https://github.com/onevcat/Kingfisher"
                )
                creditRow(
                    name: "SwiftSoup",
                    description: "HTML 解析",
                    url: "https://github.com/scinfu/SwiftSoup"
                )
            } header: {
                Text("开源库")
            } footer: {
                Text("感谢这些优秀的开源项目")
            }
        }
        .navigationTitle("致谢")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $safariURL) { item in
            SafariView(url: item.url)
        }
    }

    @ViewBuilder
    private func creditRow(name: String, description: String, url: String) -> some View {
        Button {
            if let url = URL(string: url) {
                safariURL = IdentifiableURL(url: url)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct CreditsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreditsPage()
        }
    }
}
