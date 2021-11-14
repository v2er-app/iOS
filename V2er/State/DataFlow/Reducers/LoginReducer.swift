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
                let account = AccountInfo(username: dailyInfo!.userName,
                            avatar: dailyInfo!.avatar)
                AccountState.saveAccount(account)
                state.dismiss = true
            } else {
                // -> is LoginParam -> psw error
                // -> is TwoStepInfo -> enabled two step log
                // dispatch(LoginDone())
            }
        default:
            break
    }
    return (state, followingAction)
}


