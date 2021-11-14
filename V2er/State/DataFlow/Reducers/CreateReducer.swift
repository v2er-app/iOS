//
//  CreatePageReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/21.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation



func createStateReducer(_ state: CreateTopicState, _ action: Action) -> (CreateTopicState, Action?) {
    var state = state
    switch action {
        case let action as CreateTopicActions.LoadDataStart:
            guard !state.isLoading else { break }
            state.isLoading = true
            break;
        case let action as CreateTopicActions.LoadDataDone:
            if case let .success(pageInfo) = action.createPageInfo {
                state.pageInfo = pageInfo
            } else {
                // load failed, retry
                if !state.retried {
                    state.retried = true
                    dispatch(CreateTopicActions.LoadDataStart())
                }
            }
        case let action as CreateTopicActions.LoadAllNodesStart:
            // TODO
            break;
        case let action as CreateTopicActions.LoadAllNodesDone:
            if case let .success(nodes) = action.result {
                let nodes = nodes! // safe here
                state.isLoading = false
                var hotSection = SectionNode(name: "热门节点", nodes: nodes.filter { HOT_NODES.contains($0.id) })
                var allSection = SectionNode(name: "其它节点", nodes: nodes.filter { !HOT_NODES.contains($0.id) })
                state.sectionNodes = [hotSection, allSection]
            } else {
                if !state.retried {
                    state.retried = true
                    dispatch(CreateTopicActions.LoadAllNodesStart())
                }
            }
        default:
            break
    }
    return (state, action)
}

struct CreateTopicActions {
    static let R: Reducer = .createfeed

    struct LoadDataStart: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let createPageInfo: APIResult<CreatePageInfo> = await APIService.shared
                .htmlGet(endpoint: .createTopic)
            dispatch(LoadDataDone(createPageInfo: createPageInfo))
        }
    }

    struct LoadDataDone: Action {
        var target: Reducer = R
        let createPageInfo: APIResult<CreatePageInfo>
    }

    struct LoadAllNodesStart: AwaitAction {
        var target: Reducer = R

        // TODO: cache here

        func execute(in store: Store) async {
            let result: APIResult<Nodes> = await APIService.shared
                .jsonGet(endpoint: .nodes)
            dispatch(LoadAllNodesDone(result: result))
        }
    }

    struct LoadAllNodesDone: Action {
        var target: Reducer = R
        let result: APIResult<Nodes>
    }

    struct PostStart: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let state = store.appState.createTopicState
            var params = Params()
            params["title"] = state.title
            params["content"] = state.content
            params["node_name"] = state.selectedNode!.id
            params["once"] = state.pageInfo!.once
            params["syntax"] = "markdown"

            let result: APIResult<FeedDetailInfo> = await APIService.shared
                .post(endpoint: .createTopic, params)
            dispatch(PostDone(result: result))
        }
    }

    struct PostDone: Action {
        var target: Reducer = R
        let result: APIResult<FeedDetailInfo>
    }

}
