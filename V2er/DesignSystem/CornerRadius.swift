//
//  CornerRadius.swift
//  V2er
//
//  Design token: consistent corner radius hierarchy.
//

import SwiftUI

enum CornerRadius {
    /// 6pt — tags, small badges
    static let small: CGFloat = 6
    /// 10pt — cards, input fields
    static let medium: CGFloat = 10
    /// 16pt — sheets, modals
    static let large: CGFloat = 16
    /// .infinity — capsule/pill shapes (toasts, capsule buttons)
    static let pill: CGFloat = .infinity
}
