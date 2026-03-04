//
//  AdaptiveTabContent.swift
//  V2er
//
//  Chooses between regular (iPad split) and compact (iPhone stack) content
//  based on horizontal size class. Used inside each Tab to avoid duplicating
//  the size-class check four times in MainPage.
//

import SwiftUI

struct AdaptiveTabContent<RegularContent: View, CompactContent: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @ViewBuilder let regularContent: () -> RegularContent
    @ViewBuilder let compactContent: () -> CompactContent

    var body: some View {
        if sizeClass == .regular {
            regularContent()
        } else {
            compactContent()
        }
    }
}
