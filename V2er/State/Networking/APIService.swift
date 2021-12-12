//
//  APIService.swift
//  APIService
//
//  Created by ghui on 2021/8/11.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup
import Kingfisher

struct APIService {
    static let HTTPS = "https:"
    static let HTTP = "http:"
    static let baseUrlString = "\(HTTPS)//www.v2ex.com"
    //    static let baseUrlWww= "https://www.v2ex.com"
    static let baseURL = URL(string: baseUrlString)!
    static let shared = APIService()
    private var session: URLSession
    private let jsonDecoder: JSONDecoder

    private init() {
        // TODO: support multi accounts
        self.session = URLSession.shared;
        jsonDecoder = JSONDecoder()
        KingfisherManager.shared.downloader.sessionConfiguration = session.configuration
    }

    func htmlGet<T: BaseModel>(endpoint: Endpoint,
                               _ params: Params? = nil,
                               requestHeaders: Params? = nil) async -> APIResult<T> {
        let rawResult = await get(endpoint: endpoint, params: params, requestHeaders: requestHeaders)
        guard rawResult.error == nil else {
            return .failure(rawResult.error!)
        }
        let result: (model: T?, error: APIError?) = await self.parse(from: rawResult.data!)
        guard result.error == nil && result.model != nil else {
            return .failure(result.error!)
        }
        //        log("htmlGet: \(result)")
        return .success(result.model)
    }

    func jsonGet<T: Codable>(endpoint: Endpoint,
                             _ params: Params? = nil) async -> APIResult<T> {
        let rawResult = await get(endpoint: endpoint, params: params)
        //        log("jsonGet: \(rawResult.data?.string)")
        guard rawResult.error == nil else {
            return .failure(rawResult.error!)
        }
        let parseTask = Task { () -> T in
            return try self.jsonDecoder.decode(T.self, from: rawResult.data!)
        }
        do {
            let resultModel = try await parseTask.value
            return .success(resultModel)
        } catch {
            log(error)
            return .failure(.decodingError())
        }
    }

    func post<T: BaseModel>(endpoint: Endpoint,
                            _ params: Params? = nil,
                            requestHeaders: Params? = nil) async -> APIResult<T> {
        let rawResult = await post(endpoint: endpoint, params: params, requestHeaders: requestHeaders)
        guard rawResult.error == nil else {
            return .failure(rawResult.error!)
        }
        let result: (model: T?, error: APIError?) = await self.parse(from: rawResult.data!)
        guard result.error == nil else {
            log("error: \(String(describing: result.model?.rawData))")
            return .failure(result.error!)
        }
        log("post.Result: \(result)")
        return .success(result.model)
    }

    private func get(endpoint: Endpoint,
                     params: Params?,
                     requestHeaders: Params? = nil) async -> RawResult {
        printCookies()
        let url = endpoint.url
        var componets = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queries = endpoint.queries()
        if let params = params {
            queries.merge(params)
        }
        for (_, value) in queries.enumerated() {
            if componets.queryItems == nil {
                componets.queryItems = []
            }
            componets.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
        }

        var request = URLRequest(url: componets.url!)
        request.httpMethod = "GET"
        request.addValue(endpoint.ua().value(), forHTTPHeaderField: UA.key)

        if let requestHeaders = requestHeaders {
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        let result: RawResult
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            result.data = data
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let httpError = HttpError(code: httpResponse.statusCode, msg: httpResponse.description)
                result.error = .networkError()
                log("request: \(request) ---> error: \(httpError)")
            } else { result.error = nil }
        } catch {
            result.error = .networkError()
            result.data = nil
        }
        return result
    }

    private func post(endpoint: Endpoint,
                      params: Params? = nil,
                      requestHeaders: Params? = nil) async -> RawResult {
        printCookies()
        let url = endpoint.url
        let componets = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var request = URLRequest(url: componets.url!)
        request.httpMethod = "POST"
        request.addValue(endpoint.ua().value(), forHTTPHeaderField: UA.key)
        if let requestHeaders = requestHeaders  {
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        request.encodeParameters(params: params)
        let result: RawResult
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            result.data = data
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let httpError = HttpError(code: httpResponse.statusCode, msg: httpResponse.description)
                result.error = .networkError()
            } else { result.error = nil }
        } catch {
            result.error = .networkError()
            result.data = nil
        }
        return result
    }

    private func parse<T: BaseModel>(from htmlData: Data) async -> (T?, APIError?) {
        let parseTask = Task { () -> T? in
            let html = htmlData.string
            let parseResult = try SwiftSoup.parse(html)
            let result = T(from: parseResult)
            if var result = result {
                result.rawData = html
            }
            return result
        }
        let result: (data: T?, error: APIError?)
        do {
            result.data = try await parseTask.value
            if result.data == nil {
                result.error = APIError.decodingError()
            } else if !result.data!.isValid() {
                result.error = handleGeneralError(htmlData.string)
            } else {
                result.error = nil
            }
        } catch {
            result.error = APIError.decodingError()
            result.data = nil
        }
        return result
    }

    private func handleGeneralError(_ html: String) -> APIError? {
        /*
         Possible general Reasons:
         1. need login but no login
         2. need login but login session is expired
         3. no premission to open the page
         4. two step login needed
         5. other errors
         */
        // 1. 2FA
        let twoStepInfo: TwoStepInfo? = parse(from: html)
        if twoStepInfo?.isValid() ?? false {
            dispatch(LoginActions.ShowTwoStepLogin(once: twoStepInfo!.once ?? .empty), .default)
            return .generalError
        }
        // 2. Login
        let loginParams: LoginParams? = parse(from: html)
        if loginParams?.isValid() ?? false {
            var reason: String = .empty
            if AccountState.hasSignIn() {
                // Login session expired
                reason = "登录已过期，请重新登录"
            } else {
                // Need login first
                reason = "请先去登录"
            }
            dispatch(LoginActions.ShowLoginPageAction(reason: reason))
            return .generalError
        }
        // 3. Redirect to home
        let feedInfo: FeedInfo? = parse(from: html)
        if feedInfo?.isValid() ?? false {
            // todo redirect to home
            return .generalError
        }
        return APIError.invalid(html)
    }

    func parse<T: BaseModel>(from html: String) -> T? {
        let parseResult = try? SwiftSoup.parse(html)
        let result = T(from: parseResult)
        if var result = result {
            result.rawData = html
        }
        return result
    }

    private func printCookies(tag: String = .empty) {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                log("\(tag) --> cookie: \(cookie.name), \(cookie.value)")
            }
        }
    }

    func clearCookie() {
        let cookieStore = HTTPCookieStorage.shared
        for cookie in cookieStore.cookies ?? [] {
            cookieStore.deleteCookie(cookie)
        }
    }

}

extension URLRequest {

    mutating func encodeParameters(params: Params?) {
        guard let params = params else { return }
        httpMethod = "POST"
        let parameterArray = params.map { (param) -> String in
            let (key, value) = param
            return "\(key)=\(self.percentEscapeString(value))"
        }
        httpBody = parameterArray.joined(separator: "&")
            .data(using: String.Encoding.utf8)
    }

    private func percentEscapeString(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }

}

enum APIError: Error {
    case noResponse(_ rawData: String = "未返回数据")
    case decodingError(_ rawData: String = "解析出错")
    case networkError(_ rawData: String = "网络错误")
    case invalid(_ rawData: String)
    case generalError
}

struct GeneralError: Error {
    let msg: String?

    init(_ msg: String?) {
        self.msg = msg
    }
}

struct HttpError: Error {
    let code: Int
    let msg: String?
}

typealias APIResult<T> = Result<T?, APIError>
typealias RawResult = (data: Data?, error: APIError?)
typealias Params = [String : String]
