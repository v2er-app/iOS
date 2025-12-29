//
//  Toast.swift
//  V2er
//
//  Created by ghui on 2021/11/11.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

// MARK: - Toast Configuration

private enum ToastConfig {
    static let dismissDelay: UInt64 = 1_500_000_000 // 1.5 seconds in nanoseconds
    static let animationDuration: Double = 0.25
}

// MARK: - Toast

final class Toast {
    var isPresented: Bool = false
    var title: String = ""
    var icon: String = ""
    var version: Int = 0 // Incremented on each new toast to trigger timer reset

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

// MARK: - ToastContainerView

/// Container responsible for presenting and auto-dismissing a toast.
///
/// Uses UUID-based tracking to prevent race conditions between multiple presentations:
/// - Each toast gets a unique `toastId`. Dismiss timers only act if their captured ID
///   matches the current one, preventing stale timers from dismissing newer toasts.
/// - The dismiss `Task` is cancelled on view disappear, tap dismiss, or before scheduling
///   a new timer, ensuring at most one active timer exists per toast.
private struct ToastContainerView<Content: View>: View {
    @Binding var isPresented: Bool
    let paddingTop: CGFloat
    let version: Int
    let content: Content

    @State private var dismissTask: Task<Void, Never>?
    @State private var toastId = UUID()
    @State private var hasScheduledDismiss = false

    var body: some View {
        content
            .background(Color.secondaryBackground.opacity(0.98))
            .cornerRadius(99)
            .shadow(color: Color.primaryText.opacity(0.12), radius: 4, y: 2)
            .padding(.top, paddingTop)
            .transition(.move(edge: .top).combined(with: .opacity))
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
                if newValue && hasScheduledDismiss {
                    // Re-presentation: reset timer for new toast
                    toastId = UUID()
                    scheduleDismiss()
                }
            }
            .onChange(of: version) { _ in
                // New toast content: reset timer
                toastId = UUID()
                scheduleDismiss()
            }
    }

    private func scheduleDismiss() {
        cancelDismissTask()
        hasScheduledDismiss = true

        let currentId = toastId
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: ToastConfig.dismissDelay)

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
        isPresented = false
    }
}

// MARK: - View Extension

extension View {
    func toast<Content: View>(isPresented: Binding<Bool>,
                              paddingTop: CGFloat = 0,
                              version: Int = 0,
                              @ViewBuilder content: () -> Content?) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented.wrappedValue, let toastContent = content() {
                ToastContainerView(
                    isPresented: isPresented,
                    paddingTop: paddingTop,
                    version: version,
                    content: toastContent
                )
            }
        }
        .animation(.easeInOut(duration: ToastConfig.animationDuration), value: isPresented.wrappedValue)
    }
}

// MARK: - Preview

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
