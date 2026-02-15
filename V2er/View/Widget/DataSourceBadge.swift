//
//  DataSourceBadge.swift
//  V2er
//
//  Created by V2er on 2026/2/15.
//

import SwiftUI

struct DataSourceBadge: View {
    @ObservedObject private var store = Store.shared
    let dataSource: DataSource?

    private var isVisible: Bool {
        store.appState.settingState.showDataSourceIndicator && dataSource != nil
    }

    var body: some View {
        if isVisible, let source = dataSource {
            HStack(spacing: 4) {
                Circle()
                    .fill(source == .apiV2 ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
                Text(source.rawValue)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )
        }
    }
}
