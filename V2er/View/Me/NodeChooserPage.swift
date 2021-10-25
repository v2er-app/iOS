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
    @State private var isEditing = false
    var nodes: SectionNodes?
    @Binding var selectedNode: Node?
    @Environment(\.dismiss) var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        contentView
    }

    var filterNodes: SectionNodes? {
        var hotSection = SectionNode(name: "热门节点",
                                     nodes: nodes?[0].nodes.filter { filterText.isEmpty || $0.text.contains(filterText) } ?? [])
        var allSection = SectionNode(name: "其它节点",
                                     nodes: nodes?[1].nodes.filter { filterText.isEmpty || $0.text.contains(filterText) } ?? [])
        return [hotSection, allSection]
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            Text("选择节点")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.vertical, 16)
            searchBar
            Spacer()
            List {
                ForEach(filterNodes ?? [] ) { section in
                    Section(header: Text(section.name)) {
                        ForEach(section.nodes) { node in
                            Button {
                                selectedNode = node
                                dismiss()
                            } label: {
                                Text(node.text)
                                    .greedyFrame(.leading)
                                    .forceClickable()
                            }
                            .listRowBackground(selectedNode == node ? Color.bgColor : Color.itemBg)
                        }
                    }
                }
            }
            .background(Color.bgColor)
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search ...", text: $filterText)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .focused($focused)
            }
            .padding(7)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .onTapGesture {
                withAnimation {
                    self.isEditing = true
                }
            }
            if isEditing {
                Button {
                    withAnimation {
                        self.isEditing = false
                        self.filterText = ""
                        self.focused = false
                    }
                } label: {
                    Text("Cancel")
                        .foregroundColor(.primary)
                }
                .padding(.trailing, 10)
            }
        }
    }

}

//struct NodeChooserPage_Previews: PreviewProvider {
//    private static var text: String = .empty
//    static var previews: some View {
//        NodeChooserPage(text: text)
//    }
//}
