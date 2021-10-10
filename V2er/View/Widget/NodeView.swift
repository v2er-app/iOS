//
//  NodeView.swift
//  V2er
//
//  Created by ghui on 2021/10/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NodeView<Data: NodeItemInfo>: View {
    let node: Data

    var body: some View {
        NavigationLink {
            TagDetailPage(tagId: node.id)
        } label: {
            Text(node.name)
                .font(.footnote)
                .foregroundColor(.black)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.lightGray)
        }
    }

}

protocol NodeItemInfo: Identifiable {
    var id: String { get }
    var name: String { get }
    var img: String? { get }
}

