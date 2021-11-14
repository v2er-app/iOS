//
//  HubView.swift
//  V2er
//
//  Created by ghui on 2021/11/11.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct HUD<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .visualBlur()
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct HudLoadingView: View {
    var body: some View {
        HUD {
            ProgressView()
                .scaleEffect(1.5)
                .padding(26)
        }
    }
}





struct HudView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.yellow
            HudLoadingView()
        }
        .greedyFrame()
        //        .background(Color.gray)
    }
}
