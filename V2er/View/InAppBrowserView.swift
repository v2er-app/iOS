//
//  InAppBrowserView.swift
//  V2er
//
//  Created by Claude on 2025/1/28.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import SwiftUI
import WebKit

struct InAppBrowserView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    @StateObject private var webViewState = InAppBrowserWebViewState()
    @State private var showShareSheet = false

    var body: some View {
        ZStack(alignment: .top) {
            // WebView - extends under navigation bar and bottom
            InAppBrowserWebViewController(url: url, state: webViewState)
                .ignoresSafeArea(edges: [.top, .bottom])

            // Progress bar at top (below status bar)
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                }
            }

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

            ToolbarItem(placement: .navigationBarTrailing) {
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
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [webViewState.currentURL ?? url])
        }
    }

    private func copyToClipboard() {
        let urlString = webViewState.currentURL?.absoluteString ?? url.absoluteString
        UIPasteboard.general.string = urlString
        Toast.show("已复制链接")
    }

    private func openInExternalBrowser() {
        let urlToOpen = webViewState.currentURL ?? url
        UIApplication.shared.open(urlToOpen)
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

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

// MARK: - WebView Controller (UIViewControllerRepresentable)

struct InAppBrowserWebViewController: UIViewControllerRepresentable {
    let url: URL
    @ObservedObject var state: InAppBrowserWebViewState

    func makeUIViewController(context: Context) -> WebViewHostController {
        let controller = WebViewHostController(url: url, state: state)
        return controller
    }

    func updateUIViewController(_ uiViewController: WebViewHostController, context: Context) {
        // No updates needed
    }
}

// MARK: - WebView Host Controller

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

        // Create WebView with zero frame initially, will be updated by Auto Layout
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .systemBackground

        // Allow content to scroll under navigation bar
        webView.scrollView.contentInsetAdjustmentBehavior = .always

        view.addSubview(webView)

        // Use Auto Layout - extend to edges for full screen effect
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

        // Load URL in viewDidAppear after syncing cookies
        if !hasLoadedURL {
            hasLoadedURL = true
            syncCookiesAndLoad()
        }
    }

    private func syncCookiesAndLoad() {
        // Sync cookies from HTTPCookieStorage to WKWebView
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

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.state.isLoading = true
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.state.isLoading = false
        }
        // Inject dark mode CSS for V2EX pages if app is in dark mode
        injectDarkModeIfNeeded(for: webView)
    }

    private func injectDarkModeIfNeeded(for webView: WKWebView) {
        guard let host = webView.url?.host,
              host.contains("v2ex.com") else {
            return
        }

        // Check if app is in dark mode
        let isDarkMode: Bool
        if let rootStyle = V2erApp.rootViewController?.overrideUserInterfaceStyle {
            switch rootStyle {
            case .dark:
                isDarkMode = true
            case .light:
                isDarkMode = false
            case .unspecified:
                // Follow system
                isDarkMode = traitCollection.userInterfaceStyle == .dark
            @unknown default:
                isDarkMode = traitCollection.userInterfaceStyle == .dark
            }
        } else {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        }

        guard isDarkMode else { return }

        // Inject V2EX night mode CSS
        let darkModeCSS = """
            :root { color-scheme: dark; }
            body, html {
                background-color: #1a1a1a !important;
                color: #e0e0e0 !important;
            }
            #Wrapper, #Main, #Rightbar {
                background-color: #1a1a1a !important;
            }
            .box, .cell, .cell_ops {
                background-color: #262626 !important;
                border-color: #3a3a3a !important;
            }
            .header, .inner {
                background-color: #262626 !important;
            }
            /* Tags */
            .node, a.node, .tag, a.tag {
                background-color: #3a3a3a !important;
                color: #ccc !important;
            }
            .topic_info, .votes {
                background-color: transparent !important;
            }
            /* Topic content */
            .topic-link, .item_title a, h1 {
                color: #e0e0e0 !important;
            }
            .topic_content, .reply_content, .markdown_body {
                color: #e0e0e0 !important;
            }
            /* Links */
            a {
                color: #4a9eff !important;
            }
            a.node:hover, a.tag:hover {
                background-color: #4a4a4a !important;
            }
            /* Meta text */
            .gray, .fade, .small, .ago, .no {
                color: #888 !important;
            }
            .snow {
                background-color: #333 !important;
            }
            /* Code blocks */
            pre, code {
                background-color: #333 !important;
                color: #e0e0e0 !important;
            }
            /* Forms */
            input, textarea, select {
                background-color: #333 !important;
                color: #e0e0e0 !important;
                border-color: #555 !important;
            }
            /* Tabs */
            .tab, .tab_current {
                background-color: #333 !important;
                color: #ccc !important;
            }
            .tab:hover {
                background-color: #444 !important;
            }
            /* Buttons */
            .super.button, .normal.button, input[type=submit] {
                background-color: #444 !important;
                color: #e0e0e0 !important;
                border-color: #555 !important;
            }
            /* Subtle backgrounds */
            .subtle {
                background-color: #2a2a2a !important;
            }
            /* Thank area */
            .thank_area {
                background-color: transparent !important;
            }
            /* Member info */
            .member-info, .balance_area {
                background-color: #262626 !important;
            }
            /* Separator */
            hr, .sep {
                border-color: #3a3a3a !important;
                background-color: #3a3a3a !important;
            }
            /* Page title */
            #page-title {
                background-color: #1a1a1a !important;
            }
            /* Embedded */
            .embedded {
                background-color: #2a2a2a !important;
                border-color: #3a3a3a !important;
            }
            """
        let js = "var style = document.createElement('style'); style.innerHTML = `\(darkModeCSS)`; document.head.appendChild(style);"
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

    // MARK: - WKUIDelegate

    // Handle links that open in new window (target="_blank")
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Load the URL in the current webview instead of opening a new one
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
