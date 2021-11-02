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

// MARK: - WebViewHandlerDelegate
// For printing values received from web app
protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
    func receivedStringValueFromWebView(value: String)
}

struct HtmlView: UIViewRepresentable, WebViewHandlerDelegate {

    let html: String?

    // Make a coordinator to co-ordinate with WKWebView's default delegate functions
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        // Enable javascript in WKWebView
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        //        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        // Here "iOSNative" is our delegate name that we pushed to the website that is being loaded
        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
        configuration.preferences = preferences

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        var content = Bundle.readString(name: "v2er", type: "html", inDir: "/www")
        content = content?.replace(segs: "{injecttedContent}", with: html ?? .empty)
        webView.loadHTMLString(content ?? .empty, baseURL: APIService.baseURL)
    }

    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
    }

    func receivedStringValueFromWebView(value: String) {
        print("String value received from web is: \(value)")
    }

    class Coordinator : NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: HtmlView
        var delegate: WebViewHandlerDelegate?

        init(_ htmlView: HtmlView) {
            self.parent = htmlView
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

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let javascriptFunction = "addClickToImg()"
            webView.evaluateJavaScript(javascriptFunction) { (response, error) in
                if let error = error {
                    print("Error calling javascript:valueGotFromIOS()")
                    print(error.localizedDescription)
                } else {
                    print("Called javascript:valueGotFromIOS()")
                }
            }
        }

    }

}
