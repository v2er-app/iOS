//
//  StatusBarController.swift
//  Insert this into your project.
//  Created by Xavier Donnellon
//

import SwiftUI

struct RootView<Content: View> : View {
    var content: Content

    init(@ViewBuilder content: ()-> Content) {
        self.content = content()
    }

    var body:some View {
        EmptyView()
            .withHostingWindow { window in
                V2erApp.rootViewController = RootHostingController(rootView: content)
                window?.rootViewController = V2erApp.rootViewController
            }
    }
}

class RootHostingController<Content: View>: UIHostingController<Content> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return V2erApp.statusBarState
    }
}

extension View {
    func statusBarStyle(_ style: UIStatusBarStyle, original: UIStatusBarStyle = .darkContent) -> some View {
        return self.onAppear {
            V2erApp.changeStatusBarStyle(style)
        }
        .onDisappear {
            V2erApp.changeStatusBarStyle(original)
        }
        .onChange(of: style) { newState in
            V2erApp.changeStatusBarStyle(newState)
        }
    }
}


