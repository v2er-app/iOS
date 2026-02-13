//
//  TwoStepLoginPage.swift
//  V2er
//
//  Created by ghui on 2021/12/12.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct TwoStepLoginPage: View {
    @State var twoStepCode: String = .empty
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dispatch(LoginActions.TwoStepLoginCancel())
                }

            VStack(spacing: Spacing.lg) {
                // Header
                Image(systemName: "lock.shield.fill")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .padding(.top, Spacing.sm)

                Text("两步验证")
                    .font(.headline)
                    .foregroundColor(.primaryText)

                Text("请输入您的两步验证码")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)

                // Input
                HStack(spacing: Spacing.md) {
                    Image(systemName: "number")
                        .font(.body)
                        .foregroundColor(.secondaryText)
                        .frame(width: 24)

                    TextField("验证码", text: $twoStepCode)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .font(.title3.monospaced())
                        .focused($isFocused)
                        .accessibilityLabel("两步验证码")
                }
                .padding(.horizontal, Spacing.lg)
                .frame(height: 50)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))

                // Buttons
                HStack(spacing: Spacing.md) {
                    Button {
                        dispatch(LoginActions.TwoStepLoginCancel())
                    } label: {
                        Text("取消")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button {
                        dispatch(LoginActions.TwoStepLogin(input: twoStepCode))
                    } label: {
                        Text("确定")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(twoStepCode.isEmpty)
                }
            }
            .padding(Spacing.xl)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            .padding(.horizontal, 40)
            .onAppear { isFocused = true }
        }
    }
}

struct TwoStepLoginPage_Previews: PreviewProvider {
    static var previews: some View {
        TwoStepLoginPage()
    }
}
