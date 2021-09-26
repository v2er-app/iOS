//
//  Persist.swift
//  V2er
//
//  Created by ghui on 2021/9/25.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct Persist {
    private static let userDefault = UserDefaults.standard

    static func save(value: Any, forkey key: String) {
        userDefault.set(value, forKey: key)
    }

    static func read(key: String, default: String = .empty) -> String {
        return userDefault.string(forKey: key) ?? `default`
    }

    static func read(key: String) -> Data? {
        return userDefault.data(forKey: key)
    }
}

