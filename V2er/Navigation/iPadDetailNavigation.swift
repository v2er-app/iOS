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

// MARK: - Environment Key (detail route replacement)

private struct iPadDetailRouteKey: EnvironmentKey {
    static let defaultValue: Binding<AppRoute?>? = nil
}

extension EnvironmentValues {
    var iPadDetailRoute: Binding<AppRoute?>? {
        get { self[iPadDetailRouteKey.self] }
        set { self[iPadDetailRouteKey.self] = newValue }
    }
}

// MARK: - Environment Key (detail path for push navigation)

private struct iPadDetailPathKey: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath>? = nil
}

extension EnvironmentValues {
    var iPadDetailPath: Binding<NavigationPath>? {
        get { self[iPadDetailPathKey.self] }
        set { self[iPadDetailPathKey.self] = newValue }
    }
}

