//
//  SplitNavigationLink.swift
//  V2er
//
//  Drop-in replacements for NavigationLink that route to the
//  iPad detail pane when inside an iPadTabSplitView, or fall
//  back to standard push navigation on iPhone / narrow layouts.
//

import SwiftUI

// MARK: - SplitNavigationLink

/// Replaces `NavigationLink(value:) { label }`.
/// On iPad split view: acts as a Button that sets the detail route.
/// On iPhone / single column: acts as a standard NavigationLink.
struct SplitNavigationLink<Label: View>: View {
    @Environment(\.iPadDetailRoute) private var iPadDetailRoute
    let route: AppRoute
    @ViewBuilder let label: () -> Label

    var body: some View {
        if let detailRoute = iPadDetailRoute {
            Button {
                detailRoute.wrappedValue = route
            } label: {
                label()
            }
        } else {
            NavigationLink(value: route) {
                label()
            }
        }
    }
}

// MARK: - Split Navigation Background Modifier

/// Replaces the hidden `NavigationLink` background pattern:
/// `.background { NavigationLink(value: route) { EmptyView() }.opacity(0) }`
///
/// On iPad split view: wraps content in a tappable area that sets the detail route.
/// On iPhone: adds the hidden NavigationLink in background (existing pattern).
struct SplitNavigationBackgroundModifier: ViewModifier {
    @Environment(\.iPadDetailRoute) private var iPadDetailRoute
    let route: AppRoute

    func body(content: Content) -> some View {
        if let detailRoute = iPadDetailRoute {
            Button {
                detailRoute.wrappedValue = route
            } label: {
                content
            }
            .buttonStyle(.plain)
        } else {
            content.background {
                NavigationLink(value: route) { EmptyView() }
                    .opacity(0)
            }
        }
    }
}

extension View {
    func splitNavigationBackground(route: AppRoute) -> some View {
        modifier(SplitNavigationBackgroundModifier(route: route))
    }
}
