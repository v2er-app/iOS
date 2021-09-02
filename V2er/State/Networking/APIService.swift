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
    let baseURL = URL(string: "https://v2ex.com")!
    static let shared = APIService()
    private var session: URLSession
    private let jsonDecoder: JSONDecoder

    private init() {
        // TODO: support multi accounts
        self.session = URLSession.shared;
        jsonDecoder = JSONDecoder()
    }

    func htmlGet<T: BaseModel>(endpoint: Endpoint,
                                  params: [String: String]? = nil) async -> APIResult<T> {
        let rawResult = await get(endpoint: endpoint, params: params)
        guard rawResult.error == nil else {
            return .failure(rawResult.error!)
        }
        let result: (model: T?, error: APIError?) = await self.parse(from: rawResult.data!)
        guard result.error == nil else {
            return .failure(result.error!)
        }
        return .success(result.model)
    }

    func jsonGet<T: Codable>(endpoint: Endpoint,
                             params: [String: String]?) async -> APIResult<T> {
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
                               params: [String: String]? = nil,
                               requestHeaders: [String: String]? = nil) async throws -> APIResult<T> {
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
                     params: [String: String]?,
                     requestHeaders: [String: String]? = nil) async -> RawResult {
        let url = baseURL.appendingPathComponent(endpoint.path())
        var componets = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        if let params = params {
            componets.queryItems = []
            for (_, value) in params.enumerated() {
                componets.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
            }
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
            } else { result.error = nil }
        } catch {
            result.error = .networkError(error)
            result.data = nil
        }
        return result
    }

    private func post(endpoint: Endpoint,
                      params: [String: String]? = nil,
                      requestHeaders: [String: String]? = nil) async -> RawResult {
        let url = baseURL.appendingPathComponent(endpoint.path())
        let componets = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var request = URLRequest(url: componets.url!)
        request.httpMethod = "POST"
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
            let doc: Document = try SwiftSoup.parse(html)
            return T(from: doc)
        }
        let result: (data: T?, error: APIError?)
        do {
            result.data = try await parseTask.value
            result.error = nil
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
}

struct HttpError: Error {
    let code: Int
    let msg: String?
}

typealias APIResult<T> = Result<T?, APIError>
typealias RawResult = (data: Data?, error: APIError?)

