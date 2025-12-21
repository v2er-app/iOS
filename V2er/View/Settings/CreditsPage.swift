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
        ScrollView {
            VStack(spacing: 0) {
                Button {
                    if let url = URL(string: "https://sov2ex.com") {
                        safariURL = IdentifiableURL(url: url)
                    }
                } label: {
                    SectionItemView("sov2ex.com", showDivider: false)
                        .padding(.top, 8)
                }
            }
        }
        .navBar("致谢")
        .sheet(item: $safariURL) { item in
            SafariView(url: item.url)
        }
    }
}

struct CreditsPage_Previews: PreviewProvider {
    static var previews: some View {
        CreditsPage()
    }
}
