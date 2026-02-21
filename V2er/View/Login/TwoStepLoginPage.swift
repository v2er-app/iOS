//
//  TwoStepLoginPage.swift
//  V2er
//
//  Created by ghui on 2021/12/12.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

private struct AuthenticatorApp: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let url: URL

    static let all: [AuthenticatorApp] = [
        .init(id: "google", name: "Google", icon: "g.circle.fill", url: URL(string: "googleauthenticator://")!),
        .init(id: "microsoft", name: "Microsoft", icon: "m.circle.fill", url: URL(string: "msauth://")!),
        .init(id: "authy", name: "Authy", icon: "a.circle.fill", url: URL(string: "authy://")!),
        .init(id: "1password", name: "1Password", icon: "1.circle.fill", url: URL(string: "onepassword://")!),
    ]

    static func installed() -> [AuthenticatorApp] {
        all.filter { UIApplication.shared.canOpenURL($0.url) }
    }
}

struct TwoStepLoginPage: View {
    @State var twoStepCode: String = .empty
    @State private var installedAuthenticators: [AuthenticatorApp] = []
    @FocusState private var isFocused: Bool
    @State private var showAuthenticators = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isFocused = false
                }

            VStack(spacing: 0) {
                // Header — tighter group for visual cohesion
                VStack(spacing: Spacing.sm) {
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
                }
                .padding(.bottom, Spacing.lg)

                // Input
                HStack(spacing: Spacing.md) {
                    Image(systemName: "number")
                        .font(.body)
                        .foregroundColor(.secondaryText)
                        .frame(width: 24)

                    TextField("验证码", text: $twoStepCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .font(.title3.monospaced())
                        .focused($isFocused)
                        .accessibilityLabel("两步验证码")
                        .onSubmit {
                            guard !twoStepCode.isEmpty else { return }
                            dispatch(LoginActions.TwoStepLogin(input: twoStepCode))
                        }
                        .onChange(of: twoStepCode) { _, newValue in
                            let filtered = newValue.filter(\.isNumber)
                            if filtered != newValue {
                                twoStepCode = filtered
                            }
                        }
                }
                .padding(.horizontal, Spacing.lg)
                .frame(height: 50)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))

                // Authenticator shortcuts
                if !installedAuthenticators.isEmpty {
                    // "Or" separator
                    HStack(spacing: Spacing.md) {
                        VStack { Divider() }
                        Text("或")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.secondaryText)
                        VStack { Divider() }
                    }
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.md)

                    // Authenticator app rows
                    VStack(spacing: Spacing.xs) {
                        ForEach(Array(installedAuthenticators.enumerated()), id: \.element.id) { index, app in
                            Button {
                                UIApplication.shared.open(app.url)
                            } label: {
                                HStack(spacing: Spacing.md) {
                                    Image(systemName: app.icon)
                                        .font(.title3)
                                        .foregroundStyle(Color.accentColor)
                                        .frame(width: 28)

                                    Text(app.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.primaryText)

                                    Spacer()

                                    Image(systemName: "arrow.up.forward.app.fill")
                                        .font(.caption2)
                                        .foregroundStyle(Color.tertiaryText)
                                }
                                .padding(.horizontal, Spacing.md)
                                .frame(minHeight: 44)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                            }
                            .opacity(showAuthenticators ? 1 : 0)
                            .offset(y: showAuthenticators ? 0 : 6)
                            .animation(
                                reduceMotion
                                    ? .none
                                    : .easeOut(duration: 0.25).delay(Double(index) * 0.06 + 0.15),
                                value: showAuthenticators
                            )
                            .accessibilityLabel("打开\(app.name)验证器")
                            .accessibilityHint("跳转到\(app.name)应用获取验证码")
                            .accessibilityAddTraits(.isLink)
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("验证器应用快捷入口")
                }

                // Buttons
                HStack(spacing: Spacing.md) {
                    Button {
                        dispatch(LoginActions.TwoStepLoginCancel())
                    } label: {
                        Text("取消")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .accessibilityHint("取消两步验证")

                    Button {
                        dispatch(LoginActions.TwoStepLogin(input: twoStepCode))
                    } label: {
                        Text("确定")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(twoStepCode.isEmpty)
                    .accessibilityHint("提交两步验证码")
                }
                .padding(.top, Spacing.xl)
            }
            .padding(Spacing.xl)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            .padding(.horizontal, 40)
            .accessibilityAddTraits(.isModal)
            .onAppear {
                isFocused = true
                installedAuthenticators = AuthenticatorApp.installed()
                showAuthenticators = true
            }
        }
    }
}

struct TwoStepLoginPage_Previews: PreviewProvider {
    static var previews: some View {
        TwoStepLoginPage()
    }
}
