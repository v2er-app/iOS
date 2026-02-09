//
//  HtmlView.swift
//  V2er
//
//  Created by ghui on 2021/11/1.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import SwiftUI
import WebKit
import Kingfisher

// MARK: - WebViewHandlerDelegate
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
            HtmlWebview(html: html, imgs: imgs, height: $height, rendered: $rendered)
                .environmentObject(Store.shared)
        }
        .frame(height: height)
    }
}

#if os(iOS)
fileprivate struct HtmlWebview: UIViewRepresentable, WebViewHandlerDelegate {
    let html: String?
    let imgs: [String]
    @Binding var height: CGFloat
    @Binding var rendered: Bool
    @State var loaded: Bool = false
    @ObservedObject private var store = Store.shared
    @Environment(\.colorScheme) var colorScheme

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        print("------makeUIView--------: \(self.rendered)")
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let wkpref = WKWebpagePreferences()
        wkpref.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
        configuration.preferences = preferences

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = false
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let isDark = determineIsDarkMode()
        webView.isOpaque = false
        webView.backgroundColor = isDark ? UIColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1E/255.0, alpha: 1.0) : UIColor.white
        webView.scrollView.backgroundColor = isDark ? UIColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1E/255.0, alpha: 1.0) : UIColor.white

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        print("------updateUIView--------: \(self.rendered)")
        var content = Bundle.readString(name: "v2er", type: "html")
        let isDark = determineIsDarkMode()

        webView.isOpaque = false
        webView.backgroundColor = isDark ? UIColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1E/255.0, alpha: 1.0) : UIColor.white
        webView.scrollView.backgroundColor = isDark ? UIColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1E/255.0, alpha: 1.0) : UIColor.white

        let fontSize = 16
        let params = "\(isDark), \(fontSize)"
        content = content?.replace(segs: "{injecttedContent}", with: html ?? .empty)
                          .replace(segs: "{INJECT_PARAMS}", with: params)
        let baseUrl = Bundle.main.bundleURL
        webView.loadHTMLString(content ?? .empty, baseURL: baseUrl)
    }

    private func determineIsDarkMode() -> Bool {
        let appearance = store.appState.settingState.appearance
        switch appearance {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            return colorScheme == .dark
        }
    }

    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
    }

    func receivedStringValueFromWebView(value: String) {
        print("String value received from web is: \(value)")
    }

    class Coordinator : NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: HtmlWebview
        var delegate: WebViewHandlerDelegate?

        init(_ webview: HtmlWebview) {
            self.parent = webview
            self.delegate = parent
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
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
                        self.parent.rendered = true
                    }
                }
            }
        }

    }

}

#elseif os(macOS)
fileprivate struct HtmlWebview: NSViewRepresentable, WebViewHandlerDelegate {
    let html: String?
    let imgs: [String]
    @Binding var height: CGFloat
    @Binding var rendered: Bool
    @State var loaded: Bool = false
    @ObservedObject private var store = Store.shared
    @Environment(\.colorScheme) var colorScheme

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let wkpref = WKWebpagePreferences()
        wkpref.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
        configuration.preferences = preferences

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        var content = Bundle.readString(name: "v2er", type: "html")
        let isDark = determineIsDarkMode()

        let fontSize = 16
        let params = "\(isDark), \(fontSize)"
        content = content?.replace(segs: "{injecttedContent}", with: html ?? .empty)
                          .replace(segs: "{INJECT_PARAMS}", with: params)
        let baseUrl = Bundle.main.bundleURL
        webView.loadHTMLString(content ?? .empty, baseURL: baseUrl)
    }

    private func determineIsDarkMode() -> Bool {
        let appearance = store.appState.settingState.appearance
        switch appearance {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            return colorScheme == .dark
        }
    }

    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
    }

    func receivedStringValueFromWebView(value: String) {
        print("String value received from web is: \(value)")
    }

    class Coordinator : NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: HtmlWebview
        var delegate: WebViewHandlerDelegate?

        init(_ webview: HtmlWebview) {
            self.parent = webview
            self.delegate = parent
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
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
            NSWorkspace.shared.open(url!)
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

        private func downloadImgs(_ webview: WKWebView) {
            for img in self.parent.imgs {
                let url = URL(string: img)!
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    Task {
                        var base64DataOrPath: String
                        if case let .success(imgData) = result {
                            // On macOS, Kingfisher returns KFCrossPlatformImage (NSImage)
                            if let tiffData = imgData.image.tiffRepresentation,
                               let bitmap = NSBitmapImageRep(data: tiffData),
                               let jpegData = bitmap.representation(using: .jpeg, properties: [:]) {
                                base64DataOrPath = "data:image/jpg;base64," + jpegData.base64EncodedString()
                            } else {
                                base64DataOrPath = "image_holder_failed.png"
                            }
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
                        self.parent.rendered = true
                    }
                }
            }
        }
    }
}
#endif
