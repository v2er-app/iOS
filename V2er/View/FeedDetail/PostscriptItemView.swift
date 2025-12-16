//
//  PostscriptItemView.swift
//  V2er
//
//  Created by Claude on 2024/12/17.
//  Copyright © 2024 lessmore.io. All rights reserved.
//

import SwiftUI

/// View for displaying a postscript/appendix item (附言) with gold left border
struct PostscriptItemView: View {
    let postscript: FeedDetailInfo.PostscriptInfo

    // Gold/amber color for the left border
    private let borderColor = Color(red: 212/255, green: 160/255, blue: 23/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.horizontal, 10)

            HStack(alignment: .top, spacing: 0) {
                // Gold left border
                Rectangle()
                    .fill(borderColor)
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: 8) {
                    // Header (e.g., "第 1 条附言  ·  2 天前")
                    if postscript.header.notEmpty() {
                        Text(postscript.header)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    // Content
                    if postscript.contentHtml.notEmpty() {
                        if #available(iOS 18.0, *) {
                            RichContentView(htmlContent: postscript.contentHtml)
                                .configuration(configurationForAppearance())
                        } else {
                            Text(postscript.contentHtml.htmlToPlainText())
                                .font(.subheadline)
                                .foregroundColor(.primaryText)
                        }
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, 10)
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 10)
        }
        .background(Color.itemBg)
    }

    @available(iOS 18.0, *)
    private func configurationForAppearance() -> RenderConfiguration {
        RenderConfiguration(
            stylesheet: .v2ex,
            enableImages: true,
            enableCodeHighlighting: true
        )
    }
}

// Extension to convert HTML to plain text as fallback
extension String {
    func htmlToPlainText() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attributedString.string
    }
}

#Preview {
    PostscriptItemView(postscript: FeedDetailInfo.PostscriptInfo(from: nil))
}
