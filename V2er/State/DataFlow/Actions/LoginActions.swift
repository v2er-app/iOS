//
//  LoginActions.swift
//  V2er
//
//  Created by ghui on 2021/9/23.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation


struct LoginActions {
    static let R: Reducer = .login

    struct FetchCaptchaAction {
        struct Start: AwaitAction {
            var target: Reducer = R
            func execute(in store: Store) async {
                let result: APIResult<LoginParams> = await APIService.shared
                    .htmlGet(endpoint: .captcha)
                dispatch(action: Done(result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R

            let result: APIResult<LoginParams>
        }
    }

    struct StartLogin: AwaitAction {
        var target: Reducer = R
        var userName: String
        var password: String
        var captcha: String

        func execute(in store: Store) async {
            guard let loginParams = store.appState.loginState.loginParams
            else { return }
            var params: Params = [:]
            params[loginParams.nameParam] = userName
            params[loginParams.pswParam] = password
            params[loginParams.captchaParam] = captcha
            params["once"] = loginParams.once
            params["next"] = "/mission/daily"
            let result: APIResult<DailyInfo> = await APIService.shared
                .htmlGet(endpoint: .signin, params)
            // dailyInfo.isValide
            // 1. Yes -> success
            // 2. No -> is LoginParam -> psw error
            //       -> is TwoStepInfo -> enabled two step log
            //            dispatch(action: LoginDone())
            dispatch(action: LoginDone(result: result))
        }

    }

    struct LoginDone: Action {
        var target: Reducer = R
        
        let result: APIResult<DailyInfo>
    }

}
