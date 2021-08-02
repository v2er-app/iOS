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
    print("insets: \(result)")
    return result;
}

extension View {
    public func debug(_ force: Bool = false) -> some View {
#if DEBUG
//        print(Mirror(reflecting: self).subjectType)
        return self.modifier(DebugModifier(force))
#endif
    }
    
    public func roundedEdge(radius: CGFloat = -1,
                            borderWidth: CGFloat = 0.4,
                            color: Color = Color.gray) -> some View {
        self.modifier(RoundedEdgeModifier(radius: radius,
                                          width: borderWidth, color: color))
    }
    
    //    public func fillTopInset() -> some View {
    //        return self.edgesIgnoringSafeArea(.top)
    //            .padding(.top, safeAreaInsets().top)
    //    }
    
}


struct DebugModifier: ViewModifier {
    private var force: Bool
    public init(_ force: Bool) {
        self.force = force
    }
    
    func body(content: Content) -> some View {
        if !isSimulator() && !force {
            content
        } else {
            content
                .border(.green, width: 1)
        }
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
                .clipShape(Capsule())
                .padding(width)
                .overlay(Capsule().stroke(color, lineWidth: width))
//                .cornerRadius(cornerRadius - width)
//                .padding(width)
//                .background(color)
//                .cornerRadius(cornerRadius)
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

struct RoundedCorner: Shape {
    
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
    
    func visualBlur(alpha: CGFloat = 1.0) -> some View {
        return self.background(VEBlur().opacity(alpha))
    }
    
    func forceClickable() -> some View {
        return self.background(Color.almostClear)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
}

extension Divider {
    func light() -> some View {
        frame(height: 0.1)
    }
}


