//
//  APIService.swift
//  APIService
//
//  Created by ghui on 2021/8/11.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct APIService {
    static let baseUrlString = "https://www.v2ex.com"
//    static let baseUrlWww= "https://www.v2ex.com"
    let baseURL = URL(string: baseUrlString)!
    static let shared = APIService()
    private var session: URLSession
    private let jsonDecoder: JSONDecoder

    private init() {
        // TODO: support multi accounts
        self.session = URLSession.shared;
        jsonDecoder = JSONDecoder()
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
        return .success(result.model)
    }

    func jsonGet<T: Codable>(endpoint: Endpoint,
                             params: Params?) async -> APIResult<T> {
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

    func POST<T: BaseModel>(endpoint: Endpoint,
                               params: Params? = nil,
                               requestHeaders: Params? = nil) async throws -> APIResult<T> {
        let rawResult = await post(endpoint: endpoint, params: params, requestHeaders: requestHeaders)
        guard rawResult.error == nil else {
            return .failure(rawResult.error!)
        }
        let result: (model: T?, error: APIError?) = await self.parse(from: rawResult.data!)
        guard result.error == nil else {
            return .failure(result.error!)
        }
        return .success(result.model)
    }

    private func get(endpoint: Endpoint,
                     params: Params?,
                     requestHeaders: Params? = nil) async -> RawResult {
        let url = baseURL.appendingPathComponent(endpoint.path())
        var componets = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queries = endpoint.queries()
        queries.merge(params)
        componets.queryItems = []
        for (_, value) in queries.enumerated() {
            componets.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
        }

        var request = URLRequest(url: componets.url!)
        request.httpMethod = "GET"
        request.addValue(endpoint.ua().value(), forHTTPHeaderField: UA.key)

        if requestHeaders != nil {
            for (key, value) in requestHeaders! {
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
        let url = baseURL.appendingPathComponent(endpoint.path())
        let componets = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var request = URLRequest(url: componets.url!)
        request.httpMethod = "POST"
        request.addValue(endpoint.ua().value(), forHTTPHeaderField: UA.key)
        if requestHeaders != nil {
            for (key, value) in requestHeaders! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if params != nil {
            let parseTask = Task { () -> Data in
                return try JSONSerialization
                    .data(withJSONObject: params!, options: .prettyPrinted)
            }
            do {
                request.httpBody = try await parseTask.value
            } catch {
                return (nil, .decodingError(error))
            }
        }

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
        let parseTask = Task { () -> T in
            let html = String(decoding: htmlData, as: UTF8.self)
            let parseResult = try SwiftSoup.parse(html)
            var result = T(from: parseResult)
            result.rawData = html
            return result
        }
        let result: (data: T?, error: APIError?)
        do {
            result.data = try await parseTask.value
            if !result.data!.isValid() {
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

}

enum APIError: Error {
    case noResponse
    case decodingError(_ error: Error?)
    case networkError(_ error: Error?)
    case invalid
}

struct HttpError: Error {
    let code: Int
    let msg: String?
}

typealias APIResult<T> = Result<T?, APIError>
typealias RawResult = (data: Data?, error: APIError?)
typealias Params = [String : String]
