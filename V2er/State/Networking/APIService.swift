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
    let baseURL = URL(string: baseUrlString)!
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
                               _ params: Params? = nil) async -> APIResult<T> {
        let rawResult = await get(endpoint: endpoint, params: params)
        guard rawResult.error == nil else {
            return .failure(rawResult.error!)
        }
        let result: (model: T?, error: APIError?) = await self.parse(from: rawResult.data!)
        guard result.error == nil && result.model != nil else {
            return .failure(result.error!)
        }
        log("htmlGet: \(result)")
        return .success(result.model)
    }

    func jsonGet<T: Codable>(endpoint: Endpoint,
                             params: Params? = nil) async -> APIResult<T> {
        let rawResult = await get(endpoint: endpoint, params: params)
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
            return .failure(.decodingError(error))
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
        let url = baseURL.appendingPathComponent(endpoint.path())
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
                result.error = .networkError(httpError)
                log("request: \(request) ---> error: \(httpError)")
            } else { result.error = nil }
        } catch {
            result.error = .networkError(error)
            result.data = nil
        }
        return result
    }

    private func post(endpoint: Endpoint,
                      params: Params? = nil,
                      requestHeaders: Params? = nil) async -> RawResult {
        printCookies()
        let url = baseURL.appendingPathComponent(endpoint.path())
        let componets = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var request = URLRequest(url: componets.url!)
//        request.httpMethod = "POST"
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
                result.error = .networkError(httpError)
            } else { result.error = nil }
        } catch {
            result.error = .networkError(error)
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
                result.error = APIError.decodingError(GeneralError("Error parse: \(htmlData.string)"))
            } else if !result.data!.isValid() {
                result.error = APIError.invalid
            } else {
                result.error = nil
            }
        } catch {
            result.error = APIError.decodingError(error)
            result.data = nil
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
    case noResponse
    case decodingError(_ error: Error?)
    case networkError(_ error: Error?)
    case invalid
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
