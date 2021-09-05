//
//  HtmlText.swift
//  HtmlText
//
//  Created by ghui on 2021/9/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

struct RichText: UIViewRepresentable {
    let html: String

    init(_ html: String) {
        self.html = html
    }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()
        DispatchQueue.main.async {
            let data = Data(self.html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                label.attributedText = attributedString
            }
        }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}
