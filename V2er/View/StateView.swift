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

    var state: ViewState { get }
}

protocol BasePageView: StateView {

}

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
