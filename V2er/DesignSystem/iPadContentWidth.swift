//
//  iPadContentWidth.swift
//  V2er
//

import SwiftUI

struct iPadContentWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

extension View {
    func iPadReadableWidth() -> some View {
        modifier(iPadContentWidth())
    }
}
