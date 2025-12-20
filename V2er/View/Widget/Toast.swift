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
            .foregroundColor(.primaryText)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
    }
}

private struct ToastContainerView<Content: View>: View {
    @Binding var isPresented: Bool
    let paddingTop: CGFloat
    let content: Content

    @State private var dismissTask: Task<Void, Never>?
    @State private var toastId = UUID()

    var body: some View {
        content
            .background(Color.secondaryBackground.opacity(0.98))
            .cornerRadius(99)
            .shadow(color: Color.primaryText.opacity(0.3), radius: 3)
            .padding(.top, paddingTop)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
            .zIndex(1)
            .onTapGesture {
                dismissToast()
            }
            .onAppear {
                scheduleDismiss()
            }
            .onDisappear {
                cancelDismissTask()
            }
            .onChange(of: isPresented) { newValue in
                if newValue {
                    toastId = UUID()
                    scheduleDismiss()
                }
            }
    }

    private func scheduleDismiss() {
        cancelDismissTask()

        let currentId = toastId
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

            guard !Task.isCancelled, toastId == currentId else { return }

            dismissToast()
        }
    }

    private func cancelDismissTask() {
        dismissTask?.cancel()
        dismissTask = nil
    }

    private func dismissToast() {
        cancelDismissTask()
        withAnimation(.easeInOut(duration: 0.25)) {
            isPresented = false
        }
    }
}

extension View {
    func toast<Content: View>(isPresented: Binding<Bool>,
                              paddingTop: CGFloat = 0,
                              @ViewBuilder content: () -> Content?) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented.wrappedValue, let toastContent = content() {
                ToastContainerView(
                    isPresented: isPresented,
                    paddingTop: paddingTop,
                    content: toastContent
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented.wrappedValue)
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
