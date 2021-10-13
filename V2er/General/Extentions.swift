//
//  Extentions.swift
//  Extentions
//
//  Created by ghui on 2021/8/19.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

extension String {
    static let `default`: String = ""
    public static let empty = `default`

    var int: Int {
        return Int(self) ?? 0
    }

    func segment(separatedBy separator: String, at index: Int = .last) -> String {
        guard self.contains(separator) else { return self }
        let segments = components(separatedBy: separator)
        let realIndex = min(index, segments.count - 1)
        return String(segments[realIndex])
    }

    func segment(from first: String) -> String {
        if var firstIndex = self.index(of: first) {
            firstIndex = self.index(firstIndex, offsetBy: 1)
            let subString = self[firstIndex..<self.endIndex]
            return String(subString)
        }
        return self
    }

    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func remove(_ seg: String) -> String {
        return replacingOccurrences(of: seg, with: "")
    }

    func notEmpty()-> Bool {
        return !isEmpty
    }
    

    func replace(segs: String..., with replacement: String) -> String {
        var result: String = self
        for seg in segs {
            guard result.contains(seg) else { continue }
            result = result.replacingOccurrences(of: seg, with: replacement)
        }
        return result
    }

    func extractDigits() -> String {
        guard !self.isEmpty else { return .default }
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

extension Optional where Wrapped == String {
    var isEmpty: Bool {
        return self?.isEmpty ?? true
    }

    var safe: String {
        return ifEmpty(.empty)
    }

    func ifEmpty(_ defaultValue: String) -> String {
        return isEmpty ? defaultValue : self!
    }
}

extension Binding {
    var raw: Value {
        return self.wrappedValue
    }

//    subscript<T>(_ key: Int) -> Binding<T> where Value == [T] {
//        .init(get: {
//            self.wrappedValue[key]
//        },
//              set: {
//            self.wrappedValue[key] = $0
//        })
//    }

    subscript<K, V>(_ key: K) -> Binding<V> where Value == [K:V], K: Hashable {
        .init(get: {
            self.wrappedValue[key]!
        },
              set: {
            self.wrappedValue[key] = $0
        })
    }
}

extension Int {
    static let `default`: Int = 0
    static let first: Int = 0
    static let last: Int = Int.max

    var string: String {
        return String(self)
    }
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
                .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension Dictionary {
    mutating func merge(_ dict: [Key: Value]?){
        guard let dict = dict else {
            return
        }

        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension Data {
    var string: String {
        return String(decoding: self, as: UTF8.self)
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
