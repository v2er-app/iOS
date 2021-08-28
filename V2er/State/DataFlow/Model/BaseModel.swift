//
//  BaseModel.swift
//  BaseModel
//
//  Created by ghui on 2021/8/21.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

protocol HtmlParsable {
    init(from htmlDoc: Document)
}

protocol BaseModel: HtmlParsable {
    init()
}


