//
//  View.swift
//  V2er
//
//  Created by Seth on 2020/6/25.
//  Copyright © 2020 lessmore.io. All rights reserved.
//

import SwiftUI
import Combine


public func topSafeAreaInset() -> UIEdgeInsets {
    var result: UIEdgeInsets
    if let insets = UIApplication.shared.windows.first?.safeAreaInsets {
        result = insets
    } else {
        let isIPhoneMini = V2erApp.deviceType == .iPhone12Mini
        let defaultInsetTop = isIPhoneMini ? 50.0 : 47.0
        let defaultInsetBottom = 34.0
        result = UIEdgeInsets.init(top: defaultInsetTop, left: 0,
                                   bottom: defaultInsetBottom, right: 0)
    }
    //    print("insets: \(result)")
    return result;
}

extension View {
    public func debug(_ force: Bool = false, _ color: Color = .green) -> some View {
#if DEBUG
        //        print(Mirror(reflecting: self).subjectType)
        return self.modifier(DebugModifier(force, color))
#endif
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
        if !isSimulator() && !force {
            content
        } else {
            content
                .border(color, width: 1)
        }
    }
}

extension View {
    func navigatable() -> some View {
        self.modifier(NavigationViewModifier())
    }
}

struct NavigationViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        NavigationView {
            content
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
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
                        self.offset = height - (bottomInset ?? 0)
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



struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct ClipCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

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
    
    func forceClickable() -> some View {
        return self.background(Color.almostClear)
    }

    public func cornerBorder(radius: CGFloat = -1,
                             borderWidth: CGFloat = 1,
                             color: Color = Color.border) -> some View {
        self.modifier(RoundedEdgeModifier(radius: radius,
                                          width: borderWidth, color: color))
    }

    func clipCorner(_ radius: CGFloat, corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]) -> some View {
        clipShape( ClipCornerShape(radius: radius, corners: corners) )
    }

    func hide(_ shouldHide: Bool = true) -> some View {
        self.opacity(shouldHide ? 0.0 : 1.0)
    }

    func divider(_ opacity: CGFloat = 1.0) -> some View {
        self.modifier(DividerModifier(opacity: opacity))
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
    case visible, // view is fully visible
         invisible, // view is hidden but takes up space
         gone // view is fully removed from the view hierarchy
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
}

//struct EmptyView: View {
//    var body: some View {
//        Color.clear.frame(width: 0, height: 0)
//    }
//}

extension LocalizedStringKey {
    static let empty: LocalizedStringKey = ""
}

extension View {
    func to<Destination: View>(@ViewBuilder destination: () -> Destination) -> some View {
        self.modifier(NavigationLinkModifider(destination: destination()))
    }
}

struct NavigationLinkModifider<Destination: View>: ViewModifier {
    let destination: Destination

    func body(content: Content) -> some View {
        NavigationLink {
            destination
        } label: {
            content
        }
    }
}


extension View {
    func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}







