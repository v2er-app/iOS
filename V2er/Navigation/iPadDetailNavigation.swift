//
//  iPadDetailNavigation.swift
//  V2er
//
//  Environment key for iPad split view detail navigation.
//  When present, child views set this binding to show content
//  in the right (detail) pane instead of pushing onto the
//  NavigationStack.
//

import SwiftUI

// MARK: - Environment Key

private struct iPadDetailRouteKey: EnvironmentKey {
    static let defaultValue: Binding<AppRoute?>? = nil
}

extension EnvironmentValues {
    var iPadDetailRoute: Binding<AppRoute?>? {
        get { self[iPadDetailRouteKey.self] }
        set { self[iPadDetailRouteKey.self] = newValue }
    }
}
