//
//  Extentions.swift
//  Extentions
//
//  Created by ghui on 2021/8/19.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

extension String {
    static let `default`: String = ""
    public static let empty = `default`

    func toInt() -> Int {
        return Int(self) ?? 0
    }

    func segment(at index: Int = .last, separatedBy separator: String) -> String {
        let segments = components(separatedBy: separator)
        let realIndex = min(index, segments.count - 1)
        return String(segments[realIndex])
    }

}

extension Int {
    static let `default`: Int = 0
    static let first: Int = 0
    static let last: Int = Int.max

    func toString() -> String {
        return String(self)
    }
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
