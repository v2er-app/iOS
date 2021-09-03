//
//  NewsContentView.swift
//  V2er
//
//  Created by Seth on 2021/7/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct NewsContentView: View {
    let content = """
    一套告诉你 CURD 操作就没有？比如 超强 UI 脚手架。。 从 ES Redis MYSQL 一些列中间件 一键勾选自动生成，所有基本库操作从追踪连到日志分析，性能警告就没有这样的东西吗？
"""
    
    var body: some View {
        VStack {
            Text(content)
                .font(.subheadline)
            Image("demo")
            Divider()
        }
        .padding(.vertical, 10)
    }
}

struct NewsContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewsContentView()
    }
}
