//
//  FeedbackHelperView.swift
//  V2er
//
//  Created by ghui on 2021/10/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedbackHelperView: View {
    var body: some View {
        formView
            .navigationTitle("帮助与反馈")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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

struct FeedbackHelperView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackHelperView()
    }
}
