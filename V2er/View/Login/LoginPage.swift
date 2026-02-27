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
    @ObservedObject private var store = Store.shared
    @State var showPassword = false
    @FocusState private var focusedField: LoginField?

    private enum LoginField: Hashable {
        case username, password, captcha
    }

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
            .toast(isPresented: toast.isPresented, paddingTop: 40, version: toast.version.raw) {
                DefaultToastView(title: toast.title.raw, icon: toast.icon.raw)
            }
            .alert("提示", isPresented: bindingState.showAlert) {
                Button("确定") {}
            } message: {
                Text(state.problemMessage)
            }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                VStack(spacing: Spacing.md) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 72, height: 72)
                        .cornerBorder(radius: 18)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .padding(.top, Spacing.xxxl)

                    Text("Login to V2EX")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primaryText)

                    Text("Sign in to join the discussion")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
                .padding(.bottom, Spacing.xxl)

                // MARK: - Input Fields Card
                VStack(spacing: 0) {
                    // Username
                    inputRow(icon: "person.fill") {
                        TextField("Username", text: bindingState.username)
                            .submitLabel(.next)
                            #if os(iOS)
                            .autocapitalization(.none)
                            .keyboardType(.asciiCapable)
                            #endif
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .username)
                            .onSubmit { focusedField = .password }
                            .accessibilityLabel("用户名")
                    }

                    Divider().padding(.leading, 52)

                    // Password
                    inputRow(icon: "lock.fill") {
                        Group {
                            if !showPassword {
                                SecureField("Password", text: bindingState.password)
                            } else {
                                TextField("Password", text: bindingState.password)
                            }
                        }
                        #if os(iOS)
                        .autocapitalization(.none)
                        .keyboardType(.asciiCapable)
                        #endif
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .password)
                        .onSubmit { focusedField = .captcha }

                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                showPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .font(.footnote)
                                .foregroundColor(.tertiaryText)
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    Divider().padding(.leading, 52)

                    // Captcha
                    inputRow(icon: "shield.lefthalf.filled") {
                        TextField("Captcha", text: bindingState.captcha)
                            .submitLabel(.go)
                            #if os(iOS)
                            .keyboardType(.asciiCapable)
                            #endif
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .captcha)
                            .onSubmit {
                                focusedField = nil
                                if notEmpty(state.username, state.password, state.captcha) {
                                    dispatch(LoginActions.StartLogin())
                                }
                            }
                            .accessibilityLabel("验证码")

                        captchaImageView
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .padding(.horizontal, Spacing.lg)

                // MARK: - Actions
                VStack(spacing: Spacing.md) {
                    Button {
                        focusedField = nil
                        dispatch(LoginActions.StartLogin())
                    } label: {
                        if state.logining {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Login")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!notEmpty(state.username, state.password, state.captcha) || state.logining)

                    NavigationLink(value: AppRoute.webBrowser(url: APIService.baseUrlString + "/signup?r=ghui")) {
                        Text("Register")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.xl)

                Spacer(minLength: Spacing.xxxl)

                // MARK: - Footer
                HStack(spacing: Spacing.xl) {
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
                .font(.footnote.weight(.medium))
                .foregroundColor(.tertiaryText)
                .buttonStyle(.plain)
                .padding(.top, Spacing.xxl)
                .padding(.bottom, Spacing.xl)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onTapGesture { focusedField = nil }
        .navigationTitle("登录")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    bindingState.showLoginView.wrappedValue = false
                }
            }
        }
    }

    // MARK: - Components

    @ViewBuilder
    private func inputRow<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.secondaryText)
                .frame(width: 24, alignment: .center)
                .padding(.leading, Spacing.lg)

            content()
                .frame(minHeight: 50)
        }
        .padding(.trailing, Spacing.md)
    }

    @ViewBuilder
    private var captchaImageView: some View {
        KFImage.url(URL(string: state.captchaUrl))
            .placeholder {
                ProgressView()
                    .frame(width: 120, height: 44)
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 44)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(Color.separator.opacity(0.5), lineWidth: 0.5)
            )
            .onTapGesture {
                dispatch(LoginActions.FetchCaptchaStart())
            }
            .padding(.trailing, Spacing.xs)
    }
}
