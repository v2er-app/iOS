//
//  RichText.swift
//  V2er
//
//  Created by ghui on 2021/10/26.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import UIKit
import Atributika

struct RichText: View {
    @State private var height: CGFloat = .zero
    let html: String

    init(_ html: String, maxWidth: CGFloat = 0) {
        self.html = html
    }

    var body: some View {
        AttributedText(from: html, height: $height)
    }
}

fileprivate struct AttributedText: UIViewRepresentable {
    let attributedText: Atributika.AttributedText
    @Binding var dynamicHeight: CGFloat
    @State var maxWidth: CGFloat = 300

    init(from html: String, height: Binding<CGFloat>) {
        self._dynamicHeight = height
        let all = Style.font(.systemFont(ofSize: 16))
        let link = Style("a")
            .font(.boldSystemFont(ofSize: 16))
            .foregroundColor(Color.url.uiColor, .normal)
            .backgroundColor(Color.lightGray.uiColor, .highlighted)
        let img = Style("img")
            .foregroundColor(.red, .normal)

        self.attributedText = html
            .style(tags: link)
            .styleLinks(link)
            .styleMentions(link)
            .styleHashtags(link)
            .styleAll(all)
    }

    func makeUIView(context: Context) -> MaxWidthAttributedLabel {
        let label = MaxWidthAttributedLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = self.attributedText
        label.maxWidth = maxWidth
        onClick(label: label)
        return label
    }

    private func onClick(label: MaxWidthAttributedLabel) {
        let baseURL = APIService.baseUrlString
        label.onClick = { label, detection in
            switch detection.type {
                case .hashtag(let tag):
                    if let url = URL(string: "\(baseURL)/hashtag/\(tag)") {
                        UIApplication.shared.openURL(url)
                    }
                case .mention(let name):
                    if let url = URL(string: "\(baseURL)/member/\(name)") {
                        UIApplication.shared.openURL(url)
                    }
                case .link(let url):
                    UIApplication.shared.openURL(url)
                case .tag(let tag):
                    if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                        UIApplication.shared.openURL(url)
                    }
                default:
                    break
            }
        }
    }

    func updateUIView(_ label: MaxWidthAttributedLabel, context: Context) {
        label.attributedText = self.attributedText
        onClick(label: label)
        label.maxWidth = maxWidth
    }
}

fileprivate class MaxWidthAttributedLabel: AttributedLabel {
    var maxWidth: CGFloat!

    open override var intrinsicContentSize: CGSize
    {
        sizeThatFits(CGSize(width: maxWidth, height: .infinity))
    }
}
