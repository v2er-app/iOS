//
//  StateView.swift
//  StateView
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

protocol StateView: View {
    associatedtype ViewState: FluxState

    var state: ViewState { get }
    var bindingState: Binding<ViewState> { get }
}

extension StateView {
    var state: ViewState {
        bindingState.raw
    }
}

protocol BasePageView: StateView {}

protocol BaseHomePageView: BasePageView {

}

extension BaseHomePageView {
    func scrollTop(tab: TabId) -> Bool {
        if Store.shared.appState.globalState.scrollTop == tab {
            Store.shared.appState.globalState.scrollTop = .none
            return true
        }
        return false
    }

}
