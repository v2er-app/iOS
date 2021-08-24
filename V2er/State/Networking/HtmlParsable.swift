//
//  HtmlInfo.swift
//  HtmlInfo
//
//  Created by ghui on 2021/8/16.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

protocol HtmlParsable: BaseModel {
    init?(from htmlDoc: Document)
}
