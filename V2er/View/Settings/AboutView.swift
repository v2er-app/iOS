//
//  AboutView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct AboutView: View {

    var body: some View {
        formView
            .navBar("关于")
    }

    @ViewBuilder
    private var formView: some View {
        ScrollView {
            NavigationLink {

            } label: {
                SectionItemView("FaceID")
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
