//
//  Utils.swift
//  V2er
//
//  Created by Seth on 2021/7/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import Combine
import UIKit

private let loggable: Bool = true

public func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if !loggable {
        return
    }
#if DEBUG
    print(items, separator, terminator)
#endif
}


public func isSimulator() -> Bool {
#if (arch(i386) || arch(x86_64)) && os(iOS)
    return true
#endif
    return false
}



/// Publisher to read keyboard changes.
protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
            .eraseToAnyPublisher()
    }
}
