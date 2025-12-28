//
//  Extentions.swift
//  Extentions
//
//  Created by ghui on 2021/8/19.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI
import SafariServices

extension String {
    static let `default`: String = ""
    public static let empty = `default`

    var int: Int {
        return Int(self) ?? 0
    }

    func segment(separatedBy separator: String, at index: Int = .last) -> String {
        guard self.contains(separator) else { return self }
        let segments = components(separatedBy: separator)
        let realIndex = min(index, segments.count - 1)
        return String(segments[realIndex])
    }

    func segment(from first: String) -> String {
        if var firstIndex = self.index(of: first) {
            firstIndex = self.index(firstIndex, offsetBy: 1)
            let subString = self[firstIndex..<self.endIndex]
            return String(subString)
        }
        return self
    }
    

    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func remove(_ seg: String) -> String {
        return replacingOccurrences(of: seg, with: "")
    }

    func notEmpty()-> Bool {
        return !isEmpty
    }
    

    func replace(segs: String..., with replacement: String) -> String {
        var result: String = self
        for seg in segs {
            guard result.contains(seg) else { continue }
            result = result.replacingOccurrences(of: seg, with: replacement)
        }
        return result
    }

    func extractDigits() -> String {
        guard !self.isEmpty else { return .default }
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }


    var attributedString: AttributedString {
        do {
            let attributedString = try AttributedString(markdown: self, options:
                                                            AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            return attributedString
        } catch {
            print("Couldn't parse: \(error)")
        }
        return AttributedString("Error parsing markdown")
    }

    func urlEncoded()-> String {
        let result = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return result ?? .empty
    }

    func urlDecode()-> String {
        self.removingPercentEncoding ?? .empty
    }

}

extension Optional where Wrapped == String {
    var isEmpty: Bool {
        return self?.isEmpty ?? true
    }

    var notEmpty: Bool {
        !isEmpty
    }

    var safe: String {
        return ifEmpty(.empty)
    }

    func ifEmpty(_ defaultValue: String) -> String {
        return isEmpty ? defaultValue : self!
    }
}

extension Binding {
    var raw: Value {
        return self.wrappedValue
    }

    //    subscript<T>(_ key: Int) -> Binding<T> where Value == [T] {
    //        .init(get: {
    //            self.wrappedValue[key]
    //        },
    //              set: {
    //            self.wrappedValue[key] = $0
    //        })
    //    }

    subscript<K, V>(_ key: K) -> Binding<V> where Value == [K:V], K: Hashable {
        .init(get: {
            self.wrappedValue[key]!
        },
              set: {
            self.wrappedValue[key] = $0
        })
    }
}

extension Int {
    static let `default`: Int = 0
    static let first: Int = 0
    static let last: Int = Int.max

    var string: String {
        return String(self)
    }
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
                .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension Dictionary {
    mutating func merge(_ dict: [Key: Value]?){
        guard let dict = dict else {
            return
        }

        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension Data {
    var string: String {
        return String(decoding: self, as: UTF8.self)
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}


extension UIFont {
    static func prfered(_ font: Font) -> UIFont {
        let uiFont: UIFont

        switch font {
            case .largeTitle:
                uiFont = UIFont.preferredFont(forTextStyle: .largeTitle)
            case .title:
                uiFont = UIFont.preferredFont(forTextStyle: .title1)
            case .title2:
                uiFont = UIFont.preferredFont(forTextStyle: .title2)
            case .title3:
                uiFont = UIFont.preferredFont(forTextStyle: .title3)
            case .headline:
                uiFont = UIFont.preferredFont(forTextStyle: .headline)
            case .subheadline:
                uiFont = UIFont.preferredFont(forTextStyle: .subheadline)
            case .callout:
                uiFont = UIFont.preferredFont(forTextStyle: .callout)
            case .caption:
                uiFont = UIFont.preferredFont(forTextStyle: .caption1)
            case .caption2:
                uiFont = UIFont.preferredFont(forTextStyle: .caption2)
            case .footnote:
                uiFont = UIFont.preferredFont(forTextStyle: .footnote)
            case .body:
                fallthrough
            default:
                uiFont = UIFont.preferredFont(forTextStyle: .body)
        }

        return uiFont
    }
}


extension Bundle {
    static func readString(name: String?, type: String?) -> String? {
        var result: String? = nil
        if let filepath = Bundle.main.path(forResource: name, ofType: type) {
            do {
                result = try String(contentsOfFile: filepath)
                log("----------> local resource: \(result) <------------")
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
            log("----------> local resource \(name): not found <------------")
        }
        return result
    }

}


extension URL {
    func params() -> [String : String] {
        var dict = [String : String]()

        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                for item in queryItems {
                    dict[item.name] = item.value!
                }
            }
            return dict
        } else {
            return [ : ]
        }
    }
}


// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = context.coordinator
        updateAppearance(safariVC)
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        updateAppearance(uiViewController)
    }

    private func updateAppearance(_ safariVC: SFSafariViewController) {
        // Get the actual interface style from the root view controller
        let actualStyle = V2erApp.rootViewController?.overrideUserInterfaceStyle ?? .unspecified

        // Apply the appropriate style to Safari view
        if actualStyle != .unspecified {
            // User has explicitly set light or dark mode
            safariVC.overrideUserInterfaceStyle = actualStyle
        } else {
            // Following system setting - use the current colorScheme
            safariVC.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        }

        // Set tint colors based on the effective style
        let effectiveStyle = safariVC.overrideUserInterfaceStyle == .dark ||
                           (safariVC.overrideUserInterfaceStyle == .unspecified && colorScheme == .dark)

        if effectiveStyle {
            // Dark mode colors
            safariVC.preferredControlTintColor = UIColor.systemBlue
            safariVC.preferredBarTintColor = UIColor.systemBackground
        } else {
            // Light mode colors
            safariVC.preferredControlTintColor = UIColor.systemBlue
            safariVC.preferredBarTintColor = UIColor.systemBackground
        }
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView

        init(_ parent: SafariView) {
            self.parent = parent
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.dismiss()
        }
    }
}

// MARK: - Mobile Web View (with mobile User-Agent)
import WebKit

struct MobileWebView: UIViewControllerRepresentable {
    let url: URL
    @Environment(\.colorScheme) var colorScheme

    func makeUIViewController(context: Context) -> MobileWebViewController {
        let controller = MobileWebViewController()
        controller.url = url
        controller.colorScheme = colorScheme
        return controller
    }

    func updateUIViewController(_ uiViewController: MobileWebViewController, context: Context) {
        uiViewController.colorScheme = colorScheme
    }
}

class MobileWebViewController: UIViewController, WKNavigationDelegate {
    var url: URL?
    var colorScheme: ColorScheme = .light {
        didSet {
            applyColorScheme()
        }
    }

    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var observation: NSKeyValueObservation?

    // iPhone Safari mobile User-Agent
    private static let mobileUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        setupProgressView()
        setupNavigationBar()
        applyColorScheme()

        if let url = url {
            var request = URLRequest(url: url)
            request.setValue(Self.mobileUserAgent, forHTTPHeaderField: "User-Agent")
            webView.load(request)
        }
    }

    private func applyColorScheme() {
        let isDark = colorScheme == .dark
        overrideUserInterfaceStyle = isDark ? .dark : .light
        view.backgroundColor = isDark ? .black : .white
        webView?.backgroundColor = isDark ? .black : .white
        webView?.scrollView.backgroundColor = isDark ? .black : .white
        webView?.isOpaque = false
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = Self.mobileUserAgent
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Observe loading progress
        observation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard let progress = change.newValue else { return }
            self?.progressView.progress = Float(progress)
            self?.progressView.isHidden = progress >= 1.0
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectThemeCSS()
    }

    private func injectThemeCSS() {
        let isDark = colorScheme == .dark
        // V2EX uses prefers-color-scheme, so we inject CSS to force the theme
        let css = isDark ? """
            :root { color-scheme: dark; }
            body { background-color: #1a1a1a !important; color: #e0e0e0 !important; }
            """ : """
            :root { color-scheme: light; }
            """
        let js = "var style = document.createElement('style'); style.innerHTML = `\(css)`; document.head.appendChild(style);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .systemBlue

        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
        ]
    }

    @objc private func refreshAction() {
        webView.reload()
    }

    @objc private func shareAction() {
        guard let url = webView.url else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    deinit {
        observation?.invalidate()
    }
}
