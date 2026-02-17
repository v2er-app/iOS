//
//  LoginReducer.swift
//  V2er
//
//  Created by ghui on 2021/9/23.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func loginReducer(_ state: LoginState, _ action: Action) -> (LoginState, Action?) {
    var state = state
    var followingAction: Action?
    switch action {
        case _ as LoginActions.FetchCaptchaStart:
            guard !state.loading else { break }
            state.loading = true
        case let action as LoginActions.FetchCaptchaDone:
            state.loading = false
            if case let .success(loginParams) = action.result {
                state.loginParams = loginParams
                state.captchaUrl = APIService.baseUrlString
                    .appending("/_captcha?once=")
                    .appending(loginParams!.once)
                log("captcha:\(state.captchaUrl)")
            } else if case let .failure(error) = action.result {
                // Load captcha failed
                if case let .invalid(html) = error {
                    if html.contains("登录受限") {
                        state.problemMessage = "登录受限，由于当前 IP 在短时间内的登录尝试次数太多，请稍后再试。"
                        state.showAlert = true
                    }
                } else {
                    Toast.show("登录参数加载出错", target: .login)
                }
            }
        case let action as LoginActions.ShowLoginPageAction:
            guard !state.showLoginView else { break }
            state.showLoginView = true
            Toast.show(action.reason, target: .login)
        case _ as LoginActions.StartLogin:
            guard !state.loading && !state.logining else { break }
            state.logining = true
        case let action as LoginActions.LoginDone:
            state.logining = false
            if case let .success(dailyInfo) = action.result {
                // login success
                Toast.show("登录成功")
                let account = AccountInfo(username: dailyInfo!.userName,
                                          avatar: dailyInfo!.avatar)
                AccountState.saveAccount(account)
                state.showLoginView = false
            } else if case let .failure(error) = action.result {
                // Refresh captcha after any login failure
                followingAction = LoginActions.FetchCaptchaStart()
                if case let .invalid(html) = error {
                    let loginParam: LoginParams? = APIService.shared.parse(from: html)
                    guard let loginParam = loginParam else { break }
                    let problemHtml = loginParam.problem
                    if problemHtml.notEmpty {
                        state.problemMessage = problemHtml!
                            .replace(segs: "<ul>","</ul>","<li>","</li>", with: .empty)
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        state.problemMessage = "用户名和密码无法匹配"
                    }
                    state.showAlert = true
                } else {
                    Toast.show(error, target: .login)
                }
            }
        case let action as LoginActions.ShowTwoStepLogin:
            state.showLoginView = false
            state.showTwoStepDialog = true
            state.twoFAonce = action.once
        case _ as LoginActions.TwoStepLogin:
            state.showTwoStepDialog = false
//            state.showLoginView = false
        case let action as LoginActions.TwoStepLoginCancel:
            state.showTwoStepDialog = false
        case let action as LoginActions.TwoStepLoginDone:
            if case let .success(twoFALoginInfo) = action.result {
                Toast.show("2FA登录成功")
                let account = AccountInfo(username: twoFALoginInfo!.userName,
                                          avatar: twoFALoginInfo!.avatar)
                AccountState.saveAccount(account)
                state.showTwoStepDialog = false
                // todo refresh current page
            } else {
                Toast.show("2FA登录遇到问题")
            }
        case let action as ShowToastAction:
            state.toast.title = action.title
            state.toast.icon = action.icon
            state.toast.isPresented = true
        default:
            break
    }
    return (state, followingAction)
}


struct LoginActions {
    static let R: Reducer = .login

    struct FetchCaptchaStart: AwaitAction {
        var target: Reducer = R
        func execute(in store: Store) async {
            let result: APIResult<LoginParams> = await APIService.shared
                .htmlGet(endpoint: .captcha)
            dispatch(FetchCaptchaDone(result: result))
        }
    }

    struct FetchCaptchaDone: Action {
        var target: Reducer = R

        let result: APIResult<LoginParams>
    }

    struct StartLogin: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let state = store.appState.loginState
            guard let loginParams = state.loginParams
            else { return }
            Toast.show("登录中", target: .login)
            var params: Params = [:]
            params[loginParams.nameParam] = state.username
            params[loginParams.pswParam] = state.password
            params[loginParams.captchaParam] = state.captcha
            params["once"] = loginParams.once
            params["next"] = "/mission/daily"
            let headers: Params = ["Referer": APIService.baseUrlString.appending("/signin")]
            let result: APIResult<DailyInfo> = await APIService.shared
                .post(endpoint: .signin, params, requestHeaders: headers)
            dispatch(LoginDone(result: result))
        }

    }

    struct LoginDone: Action {
        var target: Reducer = R
        let result: APIResult<DailyInfo>
    }

    struct TwoStepLogin: AwaitAction {
        var target: Reducer = R
        let input: String

        func execute(in store: Store) async {
            let state = store.appState.loginState
            if state.twoFAonce.isEmpty && state.loginParams == nil { return }
            Toast.show("2FA验证中")
            var params: Params = [:]
            var once = state.twoFAonce
            if once.isEmpty {
                once = state.loginParams!.once
            }
            params["once"] = once
            params["code"] = input
            var headers: Params = ["Referer": Endpoint.dailyMission.url.absoluteString]
            let result: APIResult<TwoStepLoginResultInfo> = await APIService.shared
                .post(endpoint: .general(url: APIService.baseUrlString + "/2fa?next=/mission/daily"),
                      params, requestHeaders: headers)
            dispatch(TwoStepLoginDone(result: result))
        }

    }

    struct TwoStepLoginDone: Action {
        var target: Reducer = R
        let result: APIResult<TwoStepLoginResultInfo>
    }

    struct TwoStepLoginCancel: Action {
        var target: Reducer = R
    }

    struct ShowLoginPageAction: Action {
        var target: Reducer = R
        var reason: String = .empty
    }

    struct ShowTwoStepLogin: Action {
        var target: Reducer = R
        var once: String
    }

}
