//
//  Spacing.swift
//  V2er
//
//  Design token: 8pt grid spacing constants.
//

import SwiftUI

enum Spacing {
    /// 2pt — hairline gaps (e.g. between badge icon and count)
    static let xxs: CGFloat = 2
    /// 4pt — tight gaps (e.g. flow stack items)
    static let xs: CGFloat = 4
    /// 8pt — small padding (e.g. vertical padding in tags)
    static let sm: CGFloat = 8
    /// 12pt — medium padding (e.g. cell content insets)
    static let md: CGFloat = 12
    /// 16pt — large padding (e.g. section insets)
    static let lg: CGFloat = 16
    /// 20pt — extra large (e.g. toast horizontal padding)
    static let xl: CGFloat = 20
    /// 24pt — section gaps
    static let xxl: CGFloat = 24
    /// 32pt — page-level vertical spacing
    static let xxxl: CGFloat = 32
}
