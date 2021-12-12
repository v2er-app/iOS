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
            Color.dim
                .opacity(0.8)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("两步验证")
                    .font(.subheadline)
                TextField("2FA码", text: $twoStepCode)
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.8))
                    .cornerBorder(radius: 8)
                HStack(spacing: 16) {
                    Spacer()
                    Button {
                        dispatch(LoginActions.TwoStepLoginCancel())
                    } label: { Text("取消").opacity(0.8) }
                    Button {
                        dispatch(LoginActions.TwoStepLogin(input: twoStepCode))
                    } label: { Text("确定") }
                    .disabled(twoStepCode.isEmpty)
                }
                .foregroundColor(.bodyText)
            }
            .padding(20)
            .visualBlur()
            .cornerBorder(radius: 20, borderWidth: 0)
            .padding(50)
        }

    }
}

struct TwoStepLoginPage_Previews: PreviewProvider {
    static var previews: some View {
        TwoStepLoginPage()
    }
}
