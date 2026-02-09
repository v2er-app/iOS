//
//  View.swift
//  V2er
//
//  Created by Seth on 2020/6/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
import Combine

#if os(iOS)
public func topSafeAreaInset() -> UIEdgeInsets {
    var result: UIEdgeInsets
    if let insets = V2erApp.window?.safeAreaInsets {
        result = insets
    } else {
        let isIPhoneMini = V2erApp.deviceType == .iPhone12Mini
        let defaultInsetTop = isIPhoneMini ? 50.0 : 47.0
        let defaultInsetBottom = 34.0
        result = UIEdgeInsets.init(top: defaultInsetTop, left: 0,
                                   bottom: defaultInsetBottom, right: 0)
    }
    return result;
}
#endif

extension View {
    public func debug(_ force: Bool = false, _ color: Color = .green) -> some View {
        return self.modifier(DebugModifier(force, color))
    }
}


struct DebugModifier: ViewModifier {
    private var force: Bool
    private var color: Color
    public init(_ force: Bool, _ color: Color) {
        self.force = force
        self.color = color
    }

    func body(content: Content) -> some View {
#if DEBUG
        if !isSimulator() && !force {
            content
        } else {
            content
                .border(color, width: 1)
        }
#else
        content
#endif
    }
}

struct RoundedEdgeModifier: ViewModifier {
    var width: CGFloat = 2
    var color: Color = .black
    var cornerRadius: CGFloat = 16.0

    init(radius: CGFloat, width: CGFloat, color: Color) {
        self.cornerRadius = radius
        self.width = width
        self.color = color
    }

    func body(content: Content) -> some View {
        if cornerRadius == -1 {
            content
                .clipShape(Circle())
                .padding(width)
                .overlay(Circle().stroke(color, lineWidth: width))
        } else {
            content
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(color, lineWidth: width)
                        .padding(width/2)
                }
        }
    }
}


#if os(iOS)
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


struct KeyboardResponsiveModifier: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
                    let value = notif.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height = value.height
                    let bottomInset = topSafeAreaInset().bottom
                    withAnimation {
                        self.offset = height - (bottomInset)
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notif in
                    withAnimation {
                        self.offset = 0
                    }
                }
            }
    }
}

extension View {
    func keyboardAware() -> ModifiedContent<Self, KeyboardResponsiveModifier> {
        return modifier(KeyboardResponsiveModifier())
    }
}
#endif



struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

#if os(iOS)
struct ClipCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#else
struct RectCorner: OptionSet {
    let rawValue: UInt
    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomLeft = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct ClipCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tl = corners.contains(.topLeft) ? radius : 0
        let tr = corners.contains(.topRight) ? radius : 0
        let bl = corners.contains(.bottomLeft) ? radius : 0
        let br = corners.contains(.bottomRight) ? radius : 0

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 { path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false) }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 { path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false) }
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 { path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false) }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 { path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false) }
        path.closeSubpath()
        return path
    }
}
#endif

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background{
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }

    func greedyWidth(_ alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }

    func greedyHeight(_ alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }

    func greedyFrame(_ alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    func visualBlur(alpha: CGFloat = 1.0, bg: Color = .clear) -> some View {
        return self.background(VEBlur(bg: bg).opacity(alpha))
    }

    public func cornerBorder(radius: CGFloat = -1,
                             borderWidth: CGFloat = 1,
                             color: Color = Color.border) -> some View {
        self.modifier(RoundedEdgeModifier(radius: radius,
                                          width: borderWidth, color: color))
    }

    #if os(iOS)
    func clipCorner(_ radius: CGFloat, corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]) -> some View {
        clipShape( ClipCornerShape(radius: radius, corners: corners) )
    }
    #else
    func clipCorner(_ radius: CGFloat, corners: RectCorner = .allCorners) -> some View {
        clipShape( ClipCornerShape(radius: radius, corners: corners) )
    }
    #endif

    func hide(_ hide: Bool = true) -> some View {
        self.opacity(hide ? 0.0 : 1.0)
    }
    func remove(_ remove: Bool = true) -> some View{
        self.modifier(HideModifier(remove: remove))
    }

    func divider(_ opacity: CGFloat = 1.0) -> some View {
        self.modifier(DividerModifier(opacity: opacity))
    }
}

struct HideModifier: ViewModifier {
    let remove: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if !remove {
            content
        }
    }
}

struct DividerModifier: ViewModifier {
    let opacity: CGFloat

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            Divider()
                .opacity(opacity)
        }
    }
}



extension Divider {
    func light() -> some View {
        frame(height: 0.2)
    }
}

enum Visibility: CaseIterable {
    case visible,
         invisible,
         gone
}

extension View {
    @ViewBuilder func visibility(_ visibility: Visibility) -> some View {
        if visibility != .gone {
            if visibility == .visible {
                self
            } else {
                hidden()
            }
        }
    }

    #if os(iOS)
    func hapticOnTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
        }
    }
    #else
    func hapticOnTap() -> some View {
        self // No haptics on macOS
    }
    #endif
}

extension LocalizedStringKey {
    static let empty: LocalizedStringKey = ""
}
