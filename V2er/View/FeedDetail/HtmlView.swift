//
//  HtmlView.swift
//  V2er
//
//  Created by ghui on 2021/11/1.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import WebKit
import Kingfisher

// MARK: - WebViewHandlerDelegate
// For printing values received from web app
protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
    func receivedStringValueFromWebView(value: String)
}

struct HtmlView: View {
    let html: String?
    let imgs: [String]
    @State var height: CGFloat = 0
    @Binding var rendered: Bool

    var body: some View {
        GeometryReader { geo in
            Webview(html: html, imgs: imgs,height: $height, rendered: $rendered)
        }
        .frame(height: height)
    }
}

fileprivate struct Webview: UIViewRepresentable, WebViewHandlerDelegate {
    let html: String?
    let imgs: [String]
    @Binding var height: CGFloat
    @Binding var rendered: Bool
    @State var loaded: Bool = false

    // Make a coordinator to co-ordinate with WKWebView's default delegate functions
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        // TODO: called many times
        print("------makeUIView--------: \(self.rendered)")
        // Enable javascript in WKWebView
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let wkpref = WKWebpagePreferences()
        wkpref.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        // Here "iOSNative" is our delegate name that we pushed to the website that is being loaded
        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
        configuration.preferences = preferences

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = false
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        print("------updateUIView--------: \(self.rendered)")
//        if rendered { return }
        var content = Bundle.readString(name: "v2er", type: "html")
        // TODO: dark mode
        let isDark = false
        let fontSize = 16
        let params = "\(isDark), \(fontSize)"
        content = content?.replace(segs: "{injecttedContent}", with: html ?? .empty)
                          .replace(segs: "{INJECT_PARAMS}", with: params)
        let baseUrl = Bundle.main.bundleURL
        webView.loadHTMLString(content ?? .empty, baseURL: baseUrl)
    }

    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
    }

    func receivedStringValueFromWebView(value: String) {
        print("String value received from web is: \(value)")
    }

    class Coordinator : NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: Webview
        var delegate: WebViewHandlerDelegate?

        init(_ webview: Webview) {
            self.parent = webview
            self.delegate = parent
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            // Make sure that your passed delegate is called
            if message.name == "iOSNative" {
                if let body = message.body as? [String: Any?] {
                    delegate?.receivedJsonValueFromWebView(value: body)
                } else if let body = message.body as? String {
                    delegate?.receivedStringValueFromWebView(value: body)
                }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            let url = navigationAction.request.url
            let navType = navigationAction.navigationType
            guard url != nil else { return .allow }
            guard navType == .linkActivated  else { return .allow }
            if url!.absoluteString.starts(with: "file:") {
                return .allow
            }
            // TODO: open in internal webview/safari
            await UIApplication.shared.openURL(url!)
            return .cancel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if webView.isLoading {
                return
            }
            downloadImgs(webView)
            injectImgClicker(webView)
            measureHeightOfHtml(webView)
        }

//        ImageCache.defaultCache.retrieveImageForKey(imageCacheKey! as String, options: nil) { (imageCacheObject, imageCacheType) -> () in
//
//            let imageData:NSData = UIImageJPEGRepresentation(imageCacheObject!, 100)!
//            strBase64 = "data:image/jpg;base64," + imageData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
//            webView.stringByEvaluatingJavaScriptFromString("setAttributeOnFly('background_image', 'xlink:href', '\(strBase64)');")!

        private func downloadImgs(_ webview: WKWebView) {
            print("------downloadImgs--------")
            for img in self.parent.imgs {
                let url = URL(string: img)!
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    Task {
                        var base64DataOrPath: String
                        if case let .success(imgData) = result {
                            base64DataOrPath = imgData.image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                            base64DataOrPath = "data:image/jpg;base64," + base64DataOrPath
                        } else {
                            base64DataOrPath = "image_holder_failed.png"
                        }
                        runInMain {
                            self.reloadImage(webview, url: img, path: base64DataOrPath)
                        }
                    }
                }
            }
        }

        private func reloadImage(_ webview: WKWebView, url: String, path: String) {
            let url = url.urlEncoded()
            let jsReloadFunction = "reloadImg('\(url)', '\(path)')"
            webview.evaluateJavaScript(jsReloadFunction) { (response, error) in
                if let error = error {
                    print("Error calling javascriptFunction: \(error)")
                }
            }
        }

        private func injectImgClicker(_ webview: WKWebView) {
            let javascriptFunction = "addClickToImg()"
            webview.evaluateJavaScript(javascriptFunction) { (response, error) in
                if let error = error {
                    print("Error calling javascriptFunction: \(error)")
                }
            }
        }

        private func measureHeightOfHtml(_ webview: WKWebView) {
            webview.evaluateJavaScript("document.documentElement.scrollHeight") { (height, error) in
                DispatchQueue.main.async {
                    self.parent.height = height as! CGFloat
                    runInMain(delay: 100) {
//                        withAnimation {
                            self.parent.rendered = true
//                        }
                    }
                }
            }
        }

    }

}
