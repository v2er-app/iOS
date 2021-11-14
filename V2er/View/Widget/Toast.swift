//
//  Toast.swift
//  V2er
//
//  Created by ghui on 2021/11/11.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

final class Toast {
    var isPresented: Bool = false
    var title: String = ""
    var icon: String = ""
    public static let shared = Toast()
    private init() {}

    static func show(_ title: String, icon: String = .empty) {
        dispatch(ShowToastAction(title: title, icon: icon))
    }
}

extension View {
    func toast<Content: View>(isPresented: Binding<Bool>,
                              @ViewBuilder content: () -> Content) -> some View {
            ZStack(alignment: .top) {
                self
                if isPresented.wrappedValue {
                    HUD { content() }
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .zIndex(1)
                }
            }
        }
}
