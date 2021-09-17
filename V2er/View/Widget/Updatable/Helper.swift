//
//  Helper.swift
//  V2er
//
//  Created by Seth on 2021/7/4.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftUI

public typealias RefreshAction = (() async-> Void)?
public typealias LoadMoreAction = (() async-> Void)?
public typealias ScrollAction = (CGFloat)->Void
