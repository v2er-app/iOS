//
//  InAppBrowserView.swift
//  V2er
//
//  Created by Claude on 2025/1/28.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import SwiftUI
import WebKit
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct InAppBrowserView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    @StateObject private var webViewState = InAppBrowserWebViewState()
    @State private var showShareSheet = false

    var body: some View {
        ZStack(alignment: .top) {
            // WebView - extends under navigation bar and bottom
            #if os(iOS)
            InAppBrowserWebViewController(url: url, state: webViewState)
                .ignoresSafeArea(edges: [.top, .bottom])
            #else
            InAppBrowserWebView_macOS(url: url, state: webViewState)
            #endif

            // Progress bar at top
            if webViewState.isLoading {
                VStack {
                    Spacer().frame(height: 0)
                    ProgressView(value: webViewState.estimatedProgress)
                        .progressViewStyle(.linear)
                        .tint(.tintColor)
                }
                .frame(maxWidth: .infinity)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                }
            }
            #endif

            #if os(iOS)
            ToolbarItem(placement: .principal) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(webViewState.title ?? "")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(webViewState.currentURL?.host ?? url.host ?? "")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(webViewState.title ?? "")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(webViewState.currentURL?.host ?? url.host ?? "")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
            }
            #endif

            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarTrailingContent
            }
            #else
            ToolbarItem(placement: .automatic) {
                toolbarTrailingContent
            }
            #endif
        }
        #if os(iOS)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [webViewState.currentURL ?? url])
        }
        #endif
    }

    @ViewBuilder
    private var toolbarTrailingContent: some View {
        HStack(spacing: 16) {
            Button {
                webViewState.goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body)
            }
            .disabled(!webViewState.canGoBack)

            Button {
                webViewState.goForward()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body)
            }
            .disabled(!webViewState.canGoForward)

            Menu {
                Button {
                    webViewState.reload()
                } label: {
                    Label("刷新", systemImage: "arrow.clockwise")
                }

                Button {
                    showShareSheet = true
                } label: {
                    Label("分享", systemImage: "square.and.arrow.up")
                }

                Button {
                    copyToClipboard()
                } label: {
                    Label("复制链接", systemImage: "doc.on.doc")
                }

                Button {
                    openInExternalBrowser()
                } label: {
                    Label("在浏览器中打开", systemImage: "safari")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body)
            }
        }
    }

    private func copyToClipboard() {
        let urlString = webViewState.currentURL?.absoluteString ?? url.absoluteString
        #if os(iOS)
        UIPasteboard.general.string = urlString
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(urlString, forType: .string)
        #endif
        Toast.show("已复制链接")
    }

    private func openInExternalBrowser() {
        let urlToOpen = webViewState.currentURL ?? url
        #if os(iOS)
        UIApplication.shared.open(urlToOpen)
        #elseif os(macOS)
        NSWorkspace.shared.open(urlToOpen)
        #endif
    }
}

// MARK: - ShareSheet (iOS only)

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

// MARK: - WebView State

class InAppBrowserWebViewState: ObservableObject {
    @Published var title: String?
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var currentURL: URL?
    @Published var estimatedProgress: Double = 0

    weak var webView: WKWebView?

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }
}

// MARK: - iOS WebView Controller

#if os(iOS)
struct InAppBrowserWebViewController: UIViewControllerRepresentable {
    let url: URL
    @ObservedObject var state: InAppBrowserWebViewState

    func makeUIViewController(context: Context) -> WebViewHostController {
        let controller = WebViewHostController(url: url, state: state)
        return controller
    }

    func updateUIViewController(_ uiViewController: WebViewHostController, context: Context) {
    }
}

class WebViewHostController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let url: URL
    private let state: InAppBrowserWebViewState
    private var webView: WKWebView!
    private var progressObserver: NSKeyValueObservation?
    private var titleObserver: NSKeyValueObservation?
    private var canGoBackObserver: NSKeyValueObservation?
    private var canGoForwardObserver: NSKeyValueObservation?
    private var urlObserver: NSKeyValueObservation?
    private var hasLoadedURL = false

    init(url: URL, state: InAppBrowserWebViewState) {
        self.url = url
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .systemBackground

        webView.scrollView.contentInsetAdjustmentBehavior = .always

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        state.webView = webView
        setupObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !hasLoadedURL {
            hasLoadedURL = true
            syncCookiesAndLoad()
        }
    }

    private func syncCookiesAndLoad() {
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore

        let group = DispatchGroup()
        for cookie in cookies {
            group.enter()
            cookieStore.setCookie(cookie) {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.webView.load(URLRequest(url: self.url))
        }
    }

    private func setupObservers() {
        progressObserver = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.state.estimatedProgress = webView.estimatedProgress
            }
        }

        titleObserver = webView.observe(\.title, options: .new) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.state.title = webView.title
            }
        }

        canGoBackObserver = webView.observe(\.canGoBack, options: .new) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.state.canGoBack = webView.canGoBack
            }
        }

        canGoForwardObserver = webView.observe(\.canGoForward, options: .new) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.state.canGoForward = webView.canGoForward
            }
        }

        urlObserver = webView.observe(\.url, options: .new) { [weak self] webView, _ in
            DispatchQueue.main.async {
                self?.state.currentURL = webView.url
            }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.state.isLoading = true
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.state.isLoading = false
        }
        injectDarkModeIfNeeded(for: webView)
    }

    private func injectDarkModeIfNeeded(for webView: WKWebView) {
        guard let host = webView.url?.host,
              host.contains("v2ex.com") else {
            return
        }

        let isDarkMode: Bool
        if let rootStyle = V2erApp.rootViewController?.overrideUserInterfaceStyle {
            switch rootStyle {
            case .dark:
                isDarkMode = true
            case .light:
                isDarkMode = false
            case .unspecified:
                isDarkMode = traitCollection.userInterfaceStyle == .dark
            @unknown default:
                isDarkMode = traitCollection.userInterfaceStyle == .dark
            }
        } else {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        }

        guard isDarkMode else { return }

        let darkModeCSS = V2exDarkModeCSS.css
        let js = V2exDarkModeCSS.injectionJS(css: darkModeCSS)
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.state.isLoading = false
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.state.isLoading = false
        }
        print("WebView failed to load: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    deinit {
        progressObserver?.invalidate()
        titleObserver?.invalidate()
        canGoBackObserver?.invalidate()
        canGoForwardObserver?.invalidate()
        urlObserver?.invalidate()
    }
}
#endif

// MARK: - macOS WebView

#if os(macOS)
struct InAppBrowserWebView_macOS: NSViewRepresentable {
    let url: URL
    @ObservedObject var state: InAppBrowserWebViewState

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        state.webView = webView
        context.coordinator.setupObservers(for: webView)

        // Sync cookies and load
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let group = DispatchGroup()
        for cookie in cookies {
            group.enter()
            cookieStore.setCookie(cookie) { group.leave() }
        }
        group.notify(queue: .main) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let state: InAppBrowserWebViewState
        private var progressObserver: NSKeyValueObservation?
        private var titleObserver: NSKeyValueObservation?
        private var canGoBackObserver: NSKeyValueObservation?
        private var canGoForwardObserver: NSKeyValueObservation?
        private var urlObserver: NSKeyValueObservation?

        init(state: InAppBrowserWebViewState) {
            self.state = state
        }

        func setupObservers(for webView: WKWebView) {
            progressObserver = webView.observe(\.estimatedProgress, options: .new) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.state.estimatedProgress = wv.estimatedProgress }
            }
            titleObserver = webView.observe(\.title, options: .new) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.state.title = wv.title }
            }
            canGoBackObserver = webView.observe(\.canGoBack, options: .new) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.state.canGoBack = wv.canGoBack }
            }
            canGoForwardObserver = webView.observe(\.canGoForward, options: .new) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.state.canGoForward = wv.canGoForward }
            }
            urlObserver = webView.observe(\.url, options: .new) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.state.currentURL = wv.url }
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async { self.state.isLoading = true }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { self.state.isLoading = false }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.state.isLoading = false }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.state.isLoading = false }
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }

        deinit {
            progressObserver?.invalidate()
            titleObserver?.invalidate()
            canGoBackObserver?.invalidate()
            canGoForwardObserver?.invalidate()
            urlObserver?.invalidate()
        }
    }
}
#endif

// MARK: - V2EX Dark Mode CSS (shared constant)

enum V2exDarkModeCSS {
    static let css = """
        :root { color-scheme: dark; }
        body, html { background-color: #1a1a1a !important; color: #e0e0e0 !important; }
        #Wrapper, #Main, #Rightbar { background-color: #1a1a1a !important; }
        .box, .cell, .cell_ops { background-color: #262626 !important; border-color: #3a3a3a !important; }
        .header, .inner { background-color: #262626 !important; }
        .node, a.node, .tag, a.tag { background-color: #3a3a3a !important; color: #ccc !important; }
        .topic_info, .votes { background-color: transparent !important; }
        .topic-link, .item_title a, h1 { color: #e0e0e0 !important; }
        .topic_content, .reply_content, .markdown_body { color: #e0e0e0 !important; }
        a { color: #4a9eff !important; }
        .gray, .fade, .small, .ago, .no { color: #888 !important; }
        .snow { background-color: #333 !important; }
        pre, code { background-color: #333 !important; color: #e0e0e0 !important; }
        input, textarea, select { background-color: #333 !important; color: #e0e0e0 !important; border-color: #555 !important; }
        .tab, .tab_current { background-color: #333 !important; color: #ccc !important; }
        .super.button, .normal.button, input[type=submit] { background-color: #444 !important; color: #e0e0e0 !important; border-color: #555 !important; }
        .subtle { background-color: #2a2a2a !important; }
        .member-info, .balance_area { background-color: #262626 !important; }
        hr, .sep { border-color: #3a3a3a !important; background-color: #3a3a3a !important; }
        .embedded { background-color: #2a2a2a !important; border-color: #3a3a3a !important; }
        """

    static func injectionJS(css: String) -> String {
        let styleElement = "document.createElement('style')"
        return "var s=\(styleElement);s.textContent=`\(css)`;document.head.appendChild(s);"
    }
}
