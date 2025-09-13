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
                    .foregroundColor(.primaryText)
                TextField("2FA码", text: $twoStepCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .foregroundColor(.primaryText)
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                HStack(spacing: 16) {
                    Spacer()
                    Button {
                        dispatch(LoginActions.TwoStepLoginCancel())
                    } label: { 
                        Text("取消")
                            .foregroundColor(.secondaryText)
                    }
                    Button {
                        dispatch(LoginActions.TwoStepLogin(input: twoStepCode))
                    } label: { 
                        Text("确定")
                            .foregroundColor(.tintColor)
                            .fontWeight(.medium)
                    }
                    .disabled(twoStepCode.isEmpty)
                }
            }
            .padding(20)
            .background(Color.secondaryBackground)
            .cornerRadius(20)
            .padding(50)
        }

    }
}

struct TwoStepLoginPage_Previews: PreviewProvider {
    static var previews: some View {
        TwoStepLoginPage()
    }
}
