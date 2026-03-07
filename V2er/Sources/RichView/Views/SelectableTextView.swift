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

    func makeCoordinator() -> Coordinator {
        Coordinator(onLinkTapped: onLinkTapped)
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
        let width = proposal.width ?? UIScreen.main.bounds.width
        let fittingSize = textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: fittingSize.height)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var onLinkTapped: ((URL) -> Void)?
        private weak var parentScrollView: UIScrollView?

        init(onLinkTapped: ((URL) -> Void)?) {
            self.onLinkTapped = onLinkTapped
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            onLinkTapped?(URL)
            return false
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            if parentScrollView == nil {
                parentScrollView = textView.findEnclosingScrollView()
            }
            // Disable scrolling while text is selected so cursor handles can move freely
            parentScrollView?.isScrollEnabled = textView.selectedRange.length == 0
        }
    }
}

/// UITextView subclass that correctly reports intrinsic content size for SwiftUI.
class SelfSizingTextView: UITextView {
    private var lastKnownWidth: CGFloat = 0

    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let size = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: size.height)
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
}
#endif
