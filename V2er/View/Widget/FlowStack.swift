//  Forked from https://github.com/globulus/swiftui-flow-layout
//  FlowStack.swift
//  FlowStack
//
//  Created by Seth on 2021/7/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

public struct FlowStack<T: Hashable, V: View>: View {
    let mode: Mode
    let data: [T]
    let horizontalSpace: CGFloat
    let verticalSpace: CGFloat
    let viewMapping: (T) -> V
    @State private var totalHeight: CGFloat
    
    public init(mode: Mode = .scrollable, data: [T],
                horizontalSpace: CGFloat = 4,
                verticalSpace: CGFloat = 4,
                viewMapping: @escaping (T) -> V) {
        self.mode = mode
        self.horizontalSpace = horizontalSpace
        self.verticalSpace = verticalSpace
        self.data = data
        self.viewMapping = viewMapping
        _totalHeight = State(initialValue: (mode == .scrollable) ? .zero : .infinity)
    }
    
    public var body: some View {
        let stack = VStack {
            GeometryReader { geometry in
                self.content(in: geometry)
            }
        }
        return Group {
            if mode == .scrollable {
                stack.frame(height: totalHeight)
            } else {
                stack.frame(maxHeight: totalHeight)
            }
        }
    }
    
    private func content(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(self.data, id: \.self) { item in
                self.viewMapping(item)
                    .padding(.horizontal, self.horizontalSpace)
                    .padding(.vertical, self.verticalSpace)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == self.data.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == self.data.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geo.frame(in: .local).size.height
            }
            return .clear
        }
    }
    
    public enum Mode {
        case scrollable, vstack
    }
}

struct FlowStack_Previews: PreviewProvider {
    static var previews: some View {
        FlowStack(data: ["问与答1", "问与答2", "99",
                         "问与答333", "问与答4", "问与答55",
                         "问与答6", "问与答77"])
        {
            Text($0)
                .font(.footnote)
                .foregroundColor(.black)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.lightGray)
                .padding(.horizontal, 5)
        }
    }
}
