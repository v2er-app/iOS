//
//  StateView.swift
//  StateView
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

public protocol StateView: View {
    associatedtype ViewState: FluxState

    var state: Binding<ViewState> { get }
}

public extension StateView {
//    @EnvironmentObject private var store: Store
}
