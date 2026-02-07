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
            .toast(isPresented: toast.isPresented, paddingTop: 40, version: toast.version.raw) {
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
            .padding(.top, Spacing.xl)
          Text("Login to V2EX")
            .font(.title2)
            .foregroundColor(.primary)
            .fontWeight(.heavy)
            .padding(.vertical, Spacing.xl)
          VStack(spacing: Spacing.md) {
            let radius: CGFloat = CornerRadius.medium
            let padding: CGFloat = Spacing.lg
            let height: CGFloat = 46
            TextField("Username", text: bindingState.username)
              .padding(.horizontal, padding)
              .frame(height: height)
              .background(Color(.systemGray6))
              .cornerRadius(radius)
              .submitLabel(.next)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .keyboardType(.asciiCapable)
              .accessibilityLabel("用户名")
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
              Color.separator
                .opacity(0.5)
                .padding(.vertical, 14)
                .frame(width: 1.5, height: height)
                .padding(.horizontal, 2)
              Button {
                withAnimation {
                  showPassword.toggle()
                }
              } label: {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                  .foregroundColor(.accentColor)
                  .font(.footnote.weight(.light))
                  .padding(.horizontal, Spacing.md)
              }
            }
            .background(Color(.systemGray6))
            .cornerRadius(radius)
            HStack(spacing: 0) {
              TextField("Captcha", text: bindingState.captcha)
                .padding(.horizontal, padding)
                .frame(height: height)
                .submitLabel(.go)
                .keyboardType(.asciiCapable)
                .disableAutocorrection(true)
                .accessibilityLabel("验证码")
              Color.separator
                .opacity(0.5)
                .padding(.vertical, 14)
                .frame(width: 1.5, height: height)
                .padding(.horizontal, 2)
              KFImage.url(URL(string: state.captchaUrl))
                .placeholder { ProgressView() }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: height)
                .onTapGesture {
                  dispatch(LoginActions.FetchCaptchaStart())
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(radius)
          }
          .padding(.horizontal, Spacing.xl)
          .padding(.bottom, Spacing.md)
          HStack {
            NavigationLink(value: AppRoute.webBrowser(url: APIService.baseUrlString + "/signup?r=ghui")) {
              Text("Register")
                .font(.headline)
                .foregroundColor(Color.accentColor)
                .padding()
                .greedyWidth()
                .cornerBorder(radius: CornerRadius.large, borderWidth: 2, color: Color.accentColor)
            }
            .buttonStyle(.plain)
            
            Button {
              dispatch(LoginActions.StartLogin())
            } label: {
              Text("Login")
                .font(.headline)
                .foregroundColor(Color(.secondarySystemGroupedBackground))
                .padding()
                .greedyWidth()
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            }
            .disabled(!notEmpty(state.username,
                                state.password,
                                state.captcha))
          }
          .padding(.horizontal, Spacing.xl)
          Spacer()
          HStack {
            NavigationLink(value: AppRoute.webBrowser(url: APIService.baseUrlString + "/faq")) {
              Text("FAQ")
            }
            NavigationLink(value: AppRoute.webBrowser(url: APIService.baseUrlString + "/about")) {
              Text("About")
            }
            NavigationLink(value: AppRoute.webBrowser(url: APIService.baseUrlString + "/forgot")) {
              Text("Password")
            }
          }
          .font(.callout.bold())
          .opacity(0.6)
          .buttonStyle(.plain)
        }
        .greedyHeight()
        .background(Color(.systemBackground))
        .navigationTitle("登录")
        .navigationBarTitleDisplayMode(.inline)
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
