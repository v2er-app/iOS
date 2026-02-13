//
//  NodeChooserPage.swift
//  V2er
//
//  Created by ghui on 2021/10/17.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NodeChooserPage: View {
    @State var filterText: String = .empty
    var nodes: SectionNodes?
    @Binding var selectedNode: Node?
    @Environment(\.dismiss) var dismiss
    @FocusState private var searchFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)

                List {
                    ForEach(filterNodes ?? []) { section in
                        Section {
                            ForEach(section.nodes) { node in
                                Button {
                                    selectedNode = node
                                    dismiss()
                                } label: {
                                    HStack {
                                        Text(node.text)
                                            .foregroundColor(.primaryText)
                                        Spacer()
                                        if selectedNode == node {
                                            Image(systemName: "checkmark")
                                                .font(.footnote.weight(.semibold))
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                                .listRowBackground(
                                    selectedNode == node
                                        ? Color.accentColor.opacity(0.08)
                                        : Color(.secondarySystemGroupedBackground)
                                )
                            }
                        } header: {
                            Text(section.name)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("选择节点")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    var filterNodes: SectionNodes? {
        guard let nodes = nodes, nodes.count >= 2 else { return nodes }
        let hotSection = SectionNode(
            name: "热门节点",
            nodes: nodes[0].nodes.filter { filterText.isEmpty || $0.text.localizedCaseInsensitiveContains(filterText) }
        )
        let allSection = SectionNode(
            name: "其它节点",
            nodes: nodes[1].nodes.filter { filterText.isEmpty || $0.text.localizedCaseInsensitiveContains(filterText) }
        )
        return [hotSection, allSection]
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundColor(.secondaryText)

            TextField("搜索节点...", text: $filterText)
                .disableAutocorrection(true)
                #if os(iOS)
                .autocapitalization(.none)
                #endif
                .focused($searchFocused)

            if !filterText.isEmpty {
                Button {
                    filterText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.tertiaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}
