//
//  TopBar.swift
//  V2er
//
//  Created by Seth on 2021/6/24.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct TopBar: View {
    @EnvironmentObject private var store: Store
    var selectedTab : TabId

    private var isHomePage: Bool {
        return selectedTab == .feed
    }

    private var title: String {
        switch selectedTab {
            case .feed:
                let selectedTab = store.appState.feedState.selectedTab
                return selectedTab == .all ? "V2EX" : selectedTab.displayName()
            case .explore:
                return "发现"
            case .message:
                return "通知"
            case .me:
                return "我"
            case .none:
                return .empty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.primary)
                        .font(.system(size: 22))
                        .padding(6)
                        .forceClickable()
                        .hide()
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                        .font(.system(size: 22))
                        .padding(6)
                        .forceClickable()
                        .to { SearchPage() }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

                // Centered title
                HStack {
                    Spacer()
                    if isHomePage {
                        HStack(spacing: 4) {
                            Text(title)
                                .font(.title2)
                                .foregroundColor(.primary)
                                .fontWeight(.heavy)
                            Image(systemName: store.appState.feedState.showFilterMenu ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)  // Expand tap area horizontally
                        .padding(.vertical, 8)     // Expand tap area vertically
                        .contentShape(Rectangle()) // Make entire padded area tappable
                        .onTapGesture {
                            // Soft haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()

                            dispatch(FeedActions.ToggleFilterMenu())
                        }
                    } else {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .allowsHitTesting(isHomePage)
            }
            .padding(.top, topSafeAreaInset().top)
            .background(VEBlur())

            Divider()
                .light()
        }
        .readSize {
            print("size: \($0))")
        }
    }
}

struct TopBar_Previews: PreviewProvider {
//    @State static var selecedTab = TabId.feed
    static var selecedTab = TabId.explore

    static var previews: some View {
        VStack {
            TopBar(selectedTab: selecedTab)
            Spacer()
        }
        .ignoresSafeArea(.container)
    }
}
