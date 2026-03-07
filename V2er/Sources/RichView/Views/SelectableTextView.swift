import SwiftUI
#if os(iOS)
import UIKit

/// A read-only, selectable text view that wraps UITextView for native cursor-based text selection.
@available(iOS 18.0, *)
struct SelectableTextView: UIViewRepresentable {
    let attributedString: AttributedString
    let fontSize: CGFloat
    let lineSpacing: CGFloat
    var onLinkTapped: ((URL) -> Void)?
    var onSelectionCleared: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(onLinkTapped: onLinkTapped, onSelectionCleared: onSelectionCleared)
    }

    func makeUIView(context: Context) -> SelfSizingTextView {
        let textView = SelfSizingTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.linkTextAttributes = [:]
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return textView
    }

    func updateUIView(_ textView: SelfSizingTextView, context: Context) {
        context.coordinator.onLinkTapped = onLinkTapped
        context.coordinator.onSelectionCleared = onSelectionCleared

        // Skip expensive NSAttributedString conversion if content hasn't changed
        if context.coordinator.lastAttributedString == attributedString {
            return
        }
        context.coordinator.lastAttributedString = attributedString
        context.coordinator.cachedSize = nil

        let nsAttr = NSMutableAttributedString(attributedString)

        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing

        let range = NSRange(location: 0, length: nsAttr.length)
        nsAttr.addAttribute(.paragraphStyle, value: style, range: range)

        // Set default UIKit font for any ranges that don't have one
        // (setCrossplatformFont in the renderer sets UIKit fonts, but some text may still lack them)
        nsAttr.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            if value == nil {
                nsAttr.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: subRange)
            }
        }

        textView.attributedText = nsAttr
        textView.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView textView: SelfSizingTextView, context: Context) -> CGSize? {
        let width: CGFloat
        if let proposedWidth = proposal.width {
            width = proposedWidth
        } else {
            let viewWidth = textView.bounds.width
            guard viewWidth > 0 else { return nil }
            width = viewWidth
        }

        // Return cached size if width hasn't changed
        if let cached = context.coordinator.cachedSize, abs(cached.width - width) < 1 {
            return cached
        }

        let fittingSize = textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        let result = CGSize(width: width, height: fittingSize.height)
        context.coordinator.cachedSize = result
        return result
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var onLinkTapped: ((URL) -> Void)?
        var onSelectionCleared: (() -> Void)?
        var lastAttributedString: AttributedString?
        var cachedSize: CGSize?
        private var hasHadSelection = false
        private weak var parentScrollView: UIScrollView?

        init(onLinkTapped: ((URL) -> Void)?, onSelectionCleared: (() -> Void)?) {
            self.onLinkTapped = onLinkTapped
            self.onSelectionCleared = onSelectionCleared
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            onLinkTapped?(URL)
            return false
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            if parentScrollView == nil {
                parentScrollView = textView.findEnclosingScrollView()
            }
            let hasSelection = textView.selectedRange.length > 0
            parentScrollView?.isScrollEnabled = !hasSelection

            if hasSelection {
                hasHadSelection = true
            } else if hasHadSelection {
                hasHadSelection = false
                // Brief delay so the user can start a new selection without dismissing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self, !self.hasHadSelection else { return }
                    self.onSelectionCleared?()
                }
            }
        }
    }
}

/// UITextView subclass that correctly reports intrinsic content size for SwiftUI.
class SelfSizingTextView: UITextView {
    private var lastKnownWidth: CGFloat = 0
    private var cachedIntrinsicHeight: CGFloat?

    override var intrinsicContentSize: CGSize {
        if let cached = cachedIntrinsicHeight {
            return CGSize(width: UIView.noIntrinsicMetric, height: cached)
        }
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let size = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        cachedIntrinsicHeight = size.height
        return CGSize(width: UIView.noIntrinsicMetric, height: size.height)
    }

    override func invalidateIntrinsicContentSize() {
        cachedIntrinsicHeight = nil
        super.invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width != lastKnownWidth {
            lastKnownWidth = bounds.width
            invalidateIntrinsicContentSize()
        }
    }

    override func copy(_ sender: Any?) {
        super.copy(sender)
        // Clear selection after copy to dismiss the context menu
        selectedTextRange = nil
    }
}

extension UIView {
    func findEnclosingScrollView() -> UIScrollView? {
        var current: UIView? = superview
        while let view = current {
            if let scrollView = view as? UIScrollView, !(view is UITextView) {
                return scrollView
            }
            current = view.superview
        }
        return nil
    }
}

#elseif os(macOS)
import AppKit

@available(macOS 15.0, *)
struct SelectableTextView: NSViewRepresentable {
    let attributedString: AttributedString
    let fontSize: CGFloat
    let lineSpacing: CGFloat
    var onLinkTapped: ((URL) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.textContainerInset = .zero
        textView.textContainer?.lineFragmentPadding = 0
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        // Skip expensive NSAttributedString conversion if content hasn't changed
        if context.coordinator.lastAttributedString == attributedString {
            return
        }
        context.coordinator.lastAttributedString = attributedString

        let nsAttr = NSMutableAttributedString(attributedString)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing

        let range = NSRange(location: 0, length: nsAttr.length)
        nsAttr.addAttribute(.paragraphStyle, value: style, range: range)

        nsAttr.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            if value == nil {
                nsAttr.addAttribute(.font, value: NSFont.systemFont(ofSize: fontSize), range: subRange)
            }
        }

        textView.textStorage?.setAttributedString(nsAttr)
    }

    class Coordinator {
        var lastAttributedString: AttributedString?
    }
}
#endif
