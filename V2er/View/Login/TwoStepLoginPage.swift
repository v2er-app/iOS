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

    var body: some View {
        ZStack {
            Color(.quaternaryLabel)
                .opacity(0.8)
                .ignoresSafeArea()
            VStack(spacing: Spacing.lg) {
                Text("两步验证")
                    .font(.subheadline)
                    .foregroundColor(Color(.label))
                TextField("2FA码", text: $twoStepCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .foregroundColor(Color(.label))
                    .padding(.vertical, Spacing.xs + 2)
                    .padding(.horizontal)
                    .accessibilityLabel("两步验证码")
                HStack(spacing: Spacing.lg) {
                    Spacer()
                    Button {
                        dispatch(LoginActions.TwoStepLoginCancel())
                    } label: { 
                        Text("取消")
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    Button {
                        dispatch(LoginActions.TwoStepLogin(input: twoStepCode))
                    } label: { 
                        Text("确定")
                            .foregroundColor(.accentColor)
                            .fontWeight(.medium)
                    }
                    .disabled(twoStepCode.isEmpty)
                }
            }
            .padding(Spacing.xl)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .padding(50)
        }

    }
}

struct TwoStepLoginPage_Previews: PreviewProvider {
    static var previews: some View {
        TwoStepLoginPage()
    }
}
