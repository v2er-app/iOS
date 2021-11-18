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
            } else {
                // Load captcha failed
            }
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
                state.dismiss = true
            } else {
                Toast.show("登录失败")
                // -> is LoginParam -> psw error
                // -> is TwoStepInfo -> enabled two step log
                // dispatch(LoginDone())
            }
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
            Toast.show("登录中")
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

}
