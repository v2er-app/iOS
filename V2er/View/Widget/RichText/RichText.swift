//
//  RichText.swift
//  V2er
//
//  Created by ghui on 2021/10/26.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import Atributika


typealias RichString = Atributika.AttributedText

struct RichText: View {
    typealias DetectionAction = (DetectionType) -> Bool
    let action: DetectionAction?
    let richString: RichString
    @State var height: CGFloat = 0

    init(_ string: ()->String, action: DetectionAction? = nil) {
        self.init({ string().rich() }, action: action)
    }

    init(_ richString: ()->RichString, action: DetectionAction? = nil) {
        self.richString = richString()
        self.action = action
    }

    var body: some View {
        GeometryReader { geo in
            AttributedTextView(richString, detection: action, maxWidth: geo.size.width, height: $height)
        }
        .frame(height: height)
    }

    struct Styles {
        #if os(iOS)
        public static let base = Style.font(UIFont.prfered(.body))
            .foregroundColor(Color.primaryText.uiColor)
        public static let link = Style("a")
            .font(.boldSystemFont(ofSize: 16))
            .foregroundColor(Color.url.uiColor, .normal)
            .backgroundColor(UIColor.systemGray6, .highlighted)
        #else
        public static let base = Style.font(NSFont.prfered(.body))
            .foregroundColor(Color.primaryText.uiColor)
        public static let link = Style("a")
            .font(.boldSystemFont(ofSize: 16))
            .foregroundColor(Color.url.uiColor, .normal)
            .backgroundColor(NSColor.controlBackgroundColor, .highlighted)
        #endif
    }
}

#if os(iOS)
fileprivate struct AttributedTextView: UIViewRepresentable {
    let richString: RichString
    let detection: RichText.DetectionAction?
    var maxWidth: CGFloat
    @Binding var height: CGFloat

    init(_ richString: RichString, detection: RichText.DetectionAction?, maxWidth: CGFloat, height: Binding<CGFloat>) {
        self.detection = detection
        self.richString = richString
        self.maxWidth = maxWidth
        self._height = height
    }

    func makeUIView(context: Context) -> AttributedLabel {
        let label = AttributedLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = self.richString
        clickEvent(label: label)
        return label
    }

    func updateUIView(_ label: AttributedLabel, context: Context) {
        label.attributedText = self.richString
        runInMain(delay: 100) {
            self.height = label.sizeThatFits(CGSize(width: maxWidth, height: .infinity)).height
        }
    }

    private func clickEvent(label: AttributedLabel) {
        let baseURL = APIService.baseUrlString
        label.onClick = { label, detection in
            if let consumed = self.detection?(detection.type) {
                if consumed { return }
            }
            switch detection.type {
                case .hashtag(let tag):
                    if let url = URL(string: "\(baseURL)/hashtag/\(tag)") {
                        url.start()
                    }
                case .mention(let name):
                    if let url = URL(string: "\(baseURL)/member/\(name)") {
                        url.start()
                    }
                case .link(let url):
                    url.start()
                case .tag(let tag):
                    if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                        url.start()
                    }
                default:
                    break
            }
        }
    }

}
#elseif os(macOS)
fileprivate struct AttributedTextView: NSViewRepresentable {
    let richString: RichString
    let detection: RichText.DetectionAction?
    var maxWidth: CGFloat
    @Binding var height: CGFloat

    init(_ richString: RichString, detection: RichText.DetectionAction?, maxWidth: CGFloat, height: Binding<CGFloat>) {
        self.detection = detection
        self.richString = richString
        self.maxWidth = maxWidth
        self._height = height
    }

    func makeNSView(context: Context) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: "")
        label.isEditable = false
        label.isSelectable = true
        label.isBordered = false
        label.drawsBackground = false
        label.allowsEditingTextAttributes = true
        label.attributedStringValue = richString.attributedString
        return label
    }

    func updateNSView(_ label: NSTextField, context: Context) {
        label.attributedStringValue = richString.attributedString
        runInMain(delay: 100) {
            let size = label.sizeThatFits(NSSize(width: maxWidth, height: .greatestFiniteMagnitude))
            self.height = size.height
        }
    }
}
#endif

extension String {
    func rich(baseStyle: Atributika.Style = RichText.Styles.base) ->RichString {
        return self
            .style(tags: RichText.Styles.link)
            .styleLinks(RichText.Styles.link)
            .styleMentions(RichText.Styles.link)
            .styleAll(baseStyle)
    }

}
