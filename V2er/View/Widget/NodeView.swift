//
//  NodeView.swift
//  V2er
//
//  Created by ghui on 2021/10/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NodeView: View {
    let id: String
    let name: String
    let img: String?

    init(id: String, name: String, img: String = .empty) {
        self.id = id
        self.name = name
        self.img = img
    }

    var body: some View {
        NavigationLink {
            TagDetailPage(tagId: id)
        } label: {
            Text(name)
                .font(.footnote)
                .foregroundColor(.black)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.lightGray)
        }
    }

}
