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

    static func show(_ title: String, icon: String = .empty, target: Reducer = .global) {
        guard title.notEmpty() || icon.notEmpty() else { return }
        dispatch(ShowToastAction(target: target, title: title, icon: icon), .default)
    }

    static func show(_ error: APIError, target: Reducer = .global) {
        let title: String
        switch error {
            case .noResponse:
                title = "未返回数据"
            case .decodingError:
                title = "解析数据出错"
            case .networkError:
                title = "网络出错"
            case .invalid:
                title = "返回数据非法"
            case .generalError:
                title = .empty
            default:
                title = "未知错误"
        }
        show(title, target: target)
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
                              paddingTop: CGFloat = 0,
                              @ViewBuilder content: () -> Content?) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented.wrappedValue {
                content()
                    .visualBlur(bg: .white.opacity(0.95))
                    .cornerRadius(99)
                    .shadow(color: .black.opacity(0.2), radius: 1.5)
                    .padding(.top, paddingTop)
                    .transition(AnyTransition.move(edge: .top))
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            isPresented.wrappedValue = false
                        }
                    }
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
