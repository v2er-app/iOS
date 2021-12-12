//
//  LoginState.swift
//  V2er
//
//  Created by ghui on 2021/9/23.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct LoginState: FluxState {
    var loading = false
    var loginParams: LoginParams?
    var captchaUrl: String = .empty
    var logining = false
    var username: String = .empty
    var password: String = .empty
    var captcha: String = .empty
    var dismiss = false
    var toast = Toast()
    var problemHtml: String? = .empty

    var showLoginView = false
    var showAlert: Bool = false
    var showTwoStepDialog = false
    var twoFAonce: String = .empty
}

struct LoginParams: BaseModel {
    var rawData: String?
    // input[type=text][autocorrect=off], name
    var nameParam: String = .default
    // input[type=password], name
    var pswParam: String = .default
    // input[name=once], value
    var once: String = .default
    // input[placeholder*=验证码], name
    var captchaParam: String = .default
    // div.problem, inner_html
    var problem: String?

    init() {}
    init(from html: Element?) {
        guard let root = html else { return }
        nameParam = root.pick("input.sl[type=text]", .name)
        pswParam = root.pick("input[type=password]", .name)
        once = root.pick("input[name=once]", .value)
        captchaParam = root.pick("input[placeholder*=验证码]", .name)
        problem = root.pick("div.problem", .innerHtml)
    }

    func isValid() -> Bool {
        return notEmpty(nameParam, pswParam, once)
    }

}
