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

private let loggable: Bool = false

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


func runInMain(delay: Int = 0, execute work: @escaping @convention(block) () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(delay), execute: work)
}

func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    let impactHeavy = UIImpactFeedbackGenerator(style: style)
    impactHeavy.impactOccurred()
}

func parseQueryParam(from url: String, param: String) -> String? {
    var tmpUrl: String = url
    if !tmpUrl.starts(with: "http") {
        tmpUrl = APIService.baseUrlString.appending(tmpUrl)
    }
    guard let tmpUrl = URLComponents(string: tmpUrl) else { return nil }
    return tmpUrl.queryItems?.first(where: { $0.name == param })?.value
}

func notEmpty(_ strs: String?...) -> Bool {
    for str in strs {
        if let str = str {
            if str.isEmpty { return false }
        } else { return false }
    }
    return true
}

extension URL {
    init?(_ url: String) {
        self.init(string: url)
    }

    func start() {
        UIApplication.shared.openURL(self)
    }
}

extension String {
    func openURL() {
        URL(self)?.start()
    }
}
