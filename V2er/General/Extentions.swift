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

    func toInt() -> Int {
        return Int(self) ?? 0
    }

}

extension Int {
    static let `default`: Int = 0

    func toString() -> String {
        return String(self)
    }
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
