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
    @State private var navigateToRoute: AppRoute?

    init(id: String, name: String, img: String = .empty) {
        self.id = id
        self.name = name
        self.img = img
    }

    var body: some View {
        Button {
            navigateToRoute = .tagDetail(tagId: id)
        } label: {
            Text(name)
                .nodeBadgeStyle()
        }
        .buttonStyle(.plain)
        .navigationDestination(item: $navigateToRoute) { route in
            route.destination()
        }
    }
}
