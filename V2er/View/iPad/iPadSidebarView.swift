//
//  iPadSidebarView.swift
//  V2er
//

import SwiftUI

struct iPadSidebarView: View {
    @Binding var selectedTab: TabId
    var unReadNums: Int
    var onReselect: (() -> Void)? = nil

    private var optionalSelection: Binding<TabId?> {
        Binding<TabId?>(
            get: { selectedTab },
            set: { newValue in
                if let newValue { selectedTab = newValue }
            }
        )
    }

    var body: some View {
        List(selection: optionalSelection) {
            Label("最新", systemImage: "newspaper")
                .tag(TabId.feed)
                .simultaneousGesture(TapGesture().onEnded {
                    if selectedTab == .feed { onReselect?() }
                })

            Label("搜索", systemImage: "magnifyingglass")
                .tag(TabId.explore)
                .simultaneousGesture(TapGesture().onEnded {
                    if selectedTab == .explore { onReselect?() }
                })

            Label {
                Text("通知")
            } icon: {
                Image(systemName: "bell")
                    .overlay(alignment: .topTrailing) {
                        if unReadNums > 0 {
                            Text("\(unReadNums)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.red, in: Capsule())
                                .offset(x: 8, y: -6)
                        }
                    }
            }
            .tag(TabId.message)
            .simultaneousGesture(TapGesture().onEnded {
                if selectedTab == .message { onReselect?() }
            })

            Label("我", systemImage: "person")
                .tag(TabId.me)
                .simultaneousGesture(TapGesture().onEnded {
                    if selectedTab == .me { onReselect?() }
                })
        }
        .listStyle(.sidebar)
        .navigationTitle("V2er")
    }
}
