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
    @Environment(\.dismiss) var dismiss
    @State var showPassword = false

    var bindingState: Binding<LoginState> {
        $store.appState.loginState
    }

    var toast: Binding<Toast> {
        bindingState.toast
    }

    var body: some View {
        contentView
            .onAppear {
                dispatch(LoginActions.FetchCaptchaStart())
            }
            .onChange(of: state.dismiss) { newValue in
                if newValue {
                    dismiss()
                }
            }
            .toast(isPresented: toast.isPresented, paddingTop: 40) {
                DefaultToastView(title: toast.title.raw, icon: toast.icon.raw)
            }
            .alert(isPresented: bindingState.showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(state.problemHtml ?? .empty),
                    primaryButton: .default(
                        Text("确定"),
                        action: { dispatch(LoginActions.FetchCaptchaStart()) }
                    ),
                    secondaryButton: .destructive(
                        Text("取消"),
                        action: { dismiss() }
                    )
                )
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
                            dispatch(LoginActions.FetchCaptchaStart())
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
                    let refUrl = APIService.baseUrlString + "/signup?r=ghui"
                    refUrl.openURL()
                } label: {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(Color.tintColor)
                        .padding()
                        .greedyWidth()
                        .cornerBorder(radius: 15, borderWidth: 2, color: Color.tintColor)
                }
                Button {
                    dispatch(LoginActions.StartLogin())
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
            Spacer()
            HStack {
                Text("FAQ")
                    .onTapGesture {
                        let url = APIService.baseUrlString + "/faq"
                        url.openURL()
                    }
                Text("About")
                    .onTapGesture {
                        let url = APIService.baseUrlString + "/about"
                        url.openURL()
                    }
                Text("Password")
                    .onTapGesture {
                        let url = APIService.baseUrlString + "/forgot"
                        url.openURL()
                    }
            }
            .font(.callout)
        }
        .greedyHeight()
        .background(Color.bgColor)
        .navigationBarHidden(true)
    }

}


//struct LoginPage_Previews: PreviewProvider {
//
//    @State static var twoStepCode: String = .empty
//    @State static var showTwoStepDialog = false
//
//    static var previews: some View {
//        VStack {
//            Text("两步验证")
//                .font(.subheadline)
//            TextField("2FA码", text: $twoStepCode)
//                .padding(.horizontal)
//                .padding(.vertical, 6)
//                .background(Color.white.opacity(0.8))
//                .cornerBorder(radius: 8)
//            HStack {
//                Spacer()
//                Button {
//                    showTwoStepDialog = false
//                } label: { Text("取消") }
//                Button {
//                    showTwoStepDialog = false
//                    // doSubmit
//                } label: { Text("确定") }
//            }
//            .foregroundColor(.bodyText)
//        }
//        .frame(width: 200)
//        .padding()
//        .visualBlur()
//        .cornerBorder(radius: 20)
//    }
//}
