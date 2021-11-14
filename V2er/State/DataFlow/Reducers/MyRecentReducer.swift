//
//  MyRecentReducer.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func myRecentStateReducer(_ state: MyRecentState, _ action: Action) -> (MyRecentState, Action?) {
    var state = state

    switch action {
        case let action as MyRecentActions.LoadDataStart:
            guard !state.loading else { break }
            state.loading = true
        case let action as MyRecentActions.LoadDataDone:
            state.loading = false
            state.records = action.result
        case let action as MyRecentActions.RecordAction:
            break
        default:
            break
    }
    return (state, action)
}

struct MyRecentActions {
    static let R: Reducer = .myrecent

    struct LoadDataStart: AwaitAction {
        var target: Reducer = R

        func execute(in store: Store) async {
            let result: [MyRecentState.Record]? = readRecordsSyncly()
            dispatch(LoadDataDone(result: result))
        }
    }

    private static func readRecordsSyncly() -> [MyRecentState.Record]? {
        var records: [MyRecentState.Record]? = nil
        do {
            let data = Persist.read(key: MyRecentState.RECORD_KEY)
            if let data = data {
                records = try JSONDecoder().decode([MyRecentState.Record].self, from: data)
                records = records?.sorted(by: >)
            }
        } catch {
            log("read records failed")
        }
        return records
    }

    struct LoadDataDone: Action {
        var target: Reducer = R
        let result: [MyRecentState.Record]?
    }

    struct RecordAction: AwaitAction {
        var target: Reducer = R
        let data: FeedInfo.Item?

        func execute(in store: Store) async {
            guard let data = data else { return }
            let newRecord: MyRecentState.Record =
            MyRecentState.Record(id: data.id,
                                 title: data.title,
                                 avatar: data.avatar,
                                 userName: data.userName,
                                 nodeName: data.nodeName,
                                 nodeId: data.nodeId,
                                 replyNum: data.replyNum)
            var records: [MyRecentState.Record] = readRecordsSyncly() ?? []
            var isAlreadyExist = false
            for (index, item) in records.enumerated() {
                if item == newRecord {
                    isAlreadyExist = true
                    records[index] = newRecord
                    break;
                }
            }
            if !isAlreadyExist {
                // check whether count >=max_capacity
                let max_capacity = 50
                if records.count >= max_capacity {
                    // delete the oldest one
                    records = records.sorted(by: > )
                    records.remove(at: max_capacity - 1)
                }
                records.append(newRecord)
            }
            // Persis to disk
            do {
                let jsonData = try JSONEncoder().encode(records)
                Persist.save(value: jsonData, forkey: MyRecentState.RECORD_KEY)
                log("Record a new item: \(newRecord)")
            } catch {
                log("Save record: \(newRecord) failed")
            }
        }
    }

}
