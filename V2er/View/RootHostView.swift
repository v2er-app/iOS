//
//  RootHostView.swift
//  V2er
//
//  Created by ghui on 2021/11/12.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct RootHostView: View {
    @EnvironmentObject private var store: Store

    var toast: Binding<Toast> {
        $store.appState.globalState.toast
    }

    var body: some View {
        MainPage()
            .buttonStyle(.plain)
            .toast(isPresented: toast.isPresented) {
                DefaultToastView(title: toast.title.raw, icon: toast.icon.raw)
            }
    }
}

struct RootHostView_Previews: PreviewProvider {
    static var previews: some View {
        RootHostView()
    }
}
