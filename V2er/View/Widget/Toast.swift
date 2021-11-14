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
        dispatch(ShowToastAction(title: title, icon: icon), .default)
    }
}

struct DefaultToastView: View {
    var title: String
    var icon: String = .empty

    var body: some View {
        Label(title, systemImage: icon)
            .foregroundColor(.bodyText)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
    }
}

extension View {
    func toast<Content: View>(isPresented: Binding<Bool>,
                              @ViewBuilder content: () -> Content?) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented.wrappedValue {
                content()
                    .visualBlur(bg: .white.opacity(0.95))
                    .cornerRadius(99)
                    .shadow(color: .black.opacity(0.2), radius: 1.5)
//                    .padding(.top, 16)
                    .transition(AnyTransition.move(edge: .top))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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

struct ToastView_Previews: PreviewProvider {
    @State static var showToast: Bool = true
    static var previews: some View {
        VStack {
            Spacer()
            Button {
                showToast.toggle()
            } label: {
                Text("Show/Hide")
                    .padding()
                    .greedyWidth()
            }
        }
        .background(.yellow)
        .greedyFrame()
        .ignoresSafeArea(.all)
        .toast(isPresented: $showToast) {
            DefaultToastView(title: "网络错误")
        }
    }
}
