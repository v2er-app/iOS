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
import SwiftUI

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


func runInMain(execute work: @escaping @convention(block) () -> Void) {
    DispatchQueue.main.async(execute: work)
}

func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    let impactHeavy = UIImpactFeedbackGenerator(style: style)
    impactHeavy.impactOccurred()
}

func parseQueryParam(from url: String, param: String) -> String? {
    guard let url = URLComponents(string: url) else { return nil }
    return url.queryItems?.first(where: { $0.name == param })?.value
}

func notEmpty(_ strs: String?...) -> Bool {
    for str in strs {
        if let str = str {
            if str.isEmpty { return false }
        } else { return false }
    }
    return true
}
