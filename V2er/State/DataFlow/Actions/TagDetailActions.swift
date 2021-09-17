//
//  TagDetailActions.swift
//  TagDetailActions
//
//  Created by ghui on 2021/9/15.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

struct TagDetailActions {
    static let R: Reducer = .tagdetail

    struct LoadMore {
        struct Start: AwaitAction {
            var target: Reducer = R
            var id: String
            let tagId: String?
            var willLoadPage: Int = 1
            var autoLoad: Bool = false

            func execute(in store: Store) async {
                let result: APIResult<TagDetailInfo> = await APIService.shared
                    .htmlGet(endpoint: .tagDetail(tagId: tagId ?? .default), params: ["p" : willLoadPage.toString()])
                dispatch(action: LoadMore.Done(id: id, result: result))
            }
        }

        struct Done: Action {
            var target: Reducer = R
            var id: String
            let result: APIResult<TagDetailInfo>
        }
    }
}
