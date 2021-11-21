//
//  CreateTopicState.swift
//  V2er
//
//  Created by ghui on 2021/10/21.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI
import SwiftSoup

struct CreateTopicState: FluxState {
    var isLoading = false
    var pageInfo: CreatePageInfo?
    var sectionNodes: SectionNodes?

    var title: String = .empty
    var content: String = .empty
    var selectedNode: Node? = nil
    var retried: Bool = false
    var posting = false
    var createResultInfo: CreateResultInfo? = nil

    mutating func reset() {
        self = CreateTopicState()
    }
}

typealias SectionNodes = [SectionNode]
struct SectionNode: Identifiable {
    var id: String { name }
    var name: String
    var nodes: Nodes
}

struct CreatePageInfo: BaseModel {
    var once: String
    var problem: Problem?

    struct Problem: HtmlParsable {
        var title: String
        var tips: [String] = []

        init?(from html: Element?) {
            guard let root = html else { return nil }
            title = root.value(.ownText)
            for e in root.pickAll("ul li") {
                tips.append(e.value())
            }
        }

        func noProblem() -> Bool {
            return tips.isEmpty
        }
    }

    init?(from html: Element?) {
        guard let root = html?.pickOne("div#Wrapper") else { return nil }
        once = root.pick("input[name=once]", .value)
        let e = root.pickOne("div.problem")
        problem = Problem(from: e)
    }


}

struct CreateResultInfo: BaseModel {
    // TODO: create topic review page
    var id: String = .empty
    init?(from html: Element?) {
        guard let root = html else { return }
        self.id = parseFeedId(root.pick("div.cell.topic_content.markdown_body h1 a", .href))
    }

    func isValid() -> Bool {
        self.id.notEmpty()
    }
}
