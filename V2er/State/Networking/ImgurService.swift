//
//  ImgurService.swift
//  V2er
//
//  Created for V2er project
//  Imgur anonymous image upload service
//

import Foundation
import UIKit

struct ImgurService {
    static let shared = ImgurService()

    // Imgur anonymous upload endpoint
    private let uploadURL = URL(string: "https://api.imgur.com/3/image")!

    // Imgur Client ID for anonymous uploads
    // Users can register their own at https://api.imgur.com/oauth2/addclient
    private let clientId = "546c25a59c58ad7"

    private init() {}

    struct UploadResult {
        let success: Bool
        let imageUrl: String?
        let error: String?
    }

    struct ImgurResponse: Codable {
        let success: Bool
        let status: Int
        let data: ImgurData?

        struct ImgurData: Codable {
            let link: String?
            let error: String?
        }
    }

    func upload(image: UIImage, quality: CGFloat = 0.8) async -> UploadResult {
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            return UploadResult(success: false, imageUrl: nil, error: "无法处理图片")
        }

        let base64String = imageData.base64EncodedString()

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.addValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = "image=\(base64String.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")"
        request.httpBody = bodyString.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return UploadResult(success: false, imageUrl: nil, error: "网络错误")
            }

            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let imgurResponse = try decoder.decode(ImgurResponse.self, from: data)

                if imgurResponse.success, let link = imgurResponse.data?.link {
                    return UploadResult(success: true, imageUrl: link, error: nil)
                } else {
                    let errorMsg = imgurResponse.data?.error ?? "上传失败"
                    return UploadResult(success: false, imageUrl: nil, error: errorMsg)
                }
            } else {
                return UploadResult(success: false, imageUrl: nil, error: "上传失败 (\(httpResponse.statusCode))")
            }
        } catch {
            log("Imgur upload error: \(error)")
            return UploadResult(success: false, imageUrl: nil, error: "上传失败: \(error.localizedDescription)")
        }
    }
}
