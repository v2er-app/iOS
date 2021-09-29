//
//  LoginPage.swift
//  V2er
//
//  Created by ghui on 2021/9/19.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import Kingfisher

struct LoginPage: StateView {
    @EnvironmentObject private var store: Store
    //    @State var username: String = .default
    @State var password: String = .default
    @State var captcha: String = .default
    @State var showPassword = false

    var bindingState: Binding<LoginState> {
        $store.appState.loginState
    }

    var state: LoginState {
        bindingState.raw
    }

    var body: some View {
        contentView
            .onAppear {
                dispatch(action: LoginActions.FetchCaptchaStart())
            }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .center) {
            Image("logo")
                .cornerBorder(radius: 25)
                .padding(.top, 20)
            Text("Login to V2EX")
                .font(.title2)
                .foregroundColor(.primary)
                .fontWeight(.heavy)
                .padding(.vertical, 20)
            VStack(spacing: 10) {
                let radius: CGFloat = 12
                let padding: CGFloat = 16
                let height: CGFloat = 46
                TextField("Username", text: bindingState.username)
                    .padding(.horizontal, padding)
                    .frame(height: height)
                    .background(Color.lightGray)
                    .cornerRadius(radius)
                    .submitLabel(.next)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.asciiCapable)
                    .debug()
                HStack(spacing: 0) {
                    Group {
                        if !showPassword {
                            SecureField("Password", text: bindingState.password)
                        } else {
                            TextField("Password", text: bindingState.password)
                        }
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.asciiCapable)
                    .submitLabel(.continue)
                    .padding(.horizontal, padding)
                    .frame(maxWidth: .infinity, maxHeight: height)
                    Color.gray
                        .opacity(0.2)
                        .padding(.vertical, 14)
                        .frame(width: 1.5, height: height)
                        .padding(.horizontal, 2)
                    Button {
                        withAnimation {
                            showPassword.toggle()
                        }
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.tintColor)
                            .font(.footnote.weight(.light))
                            .padding(.horizontal, 10)
                    }
                }
                .background(Color.lightGray)
                .cornerRadius(radius)
                HStack(spacing: 0) {
                    TextField("Captcha", text: bindingState.captcha)
                        .padding(.horizontal, padding)
                        .frame(height: height)
                        .submitLabel(.go)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                    Color.gray
                        .opacity(0.2)
                        .padding(.vertical, 14)
                        .frame(width: 1.5, height: height)
                        .padding(.horizontal, 2)
                    KFImage.url(URL(string: state.captchaUrl))
                        .placeholder { ProgressView().debug() }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: height)
                        .onTapGesture {
                            dispatch(action: LoginActions.FetchCaptchaStart())
                        }
                }
                .background(Color.lightGray)
                .cornerRadius(radius)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            HStack {
                Button {
                    // start register
                } label: {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(Color.tintColor)
                        .padding()
                        .greedyWidth()
                        .cornerBorder(radius: 15, borderWidth: 2, color: Color.tintColor)
                }
                Button {
                    dispatch(action: LoginActions.StartLogin())
                } label: {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .greedyWidth()
                        .background(Color.tintColor)
                        .cornerRadius(15)
                }
                .disabled(!notEmpty(state.username,
                                    state.password,
                                    state.captcha))
            }
            .padding(.horizontal, 20)
            Text("Sign in with Google")
                .font(.headline)
                .greedyWidth(.trailing)
                .padding(.trailing, 20)
                .padding(.vertical)
            Spacer()
            HStack {
                Text("FAQ")
                Text("About")
                Text("Password")
            }
            .font(.callout)
        }
        .greedyHeight()
        .background(Color.bgColor)
        .navigationBarHidden(true)
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
            .environmentObject(Store.shared)
    }
}
