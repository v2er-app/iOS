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

    struct FetchCaptchaStart: AwaitAction {
        var target: Reducer = R
        func execute(in store: Store) async {
            let result: APIResult<LoginParams> = await APIService.shared
                .htmlGet(endpoint: .captcha)
            dispatch(action: FetchCaptchaDone(result: result))
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
            var params: Params = [:]
            params[loginParams.nameParam] = state.username
            params[loginParams.pswParam] = state.password
            params[loginParams.captchaParam] = state.captcha
            params["once"] = loginParams.once
            params["next"] = "/mission/daily"
            let headers: Params = ["Referer": APIService.baseUrlString.appending("/signin")]
            let result: APIResult<DailyInfo> = await APIService.shared
                .post(endpoint: .signin, params, requestHeaders: headers)
            dispatch(action: LoginDone(result: result))
        }

    }

    struct LoginDone: Action {
        var target: Reducer = R
        let result: APIResult<DailyInfo>
    }

}
