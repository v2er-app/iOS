//
//  FeedTabFilter.swift
//  V2er
//
//  Created by copilot on 2024/09/20.
//  Copyright © 2024 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedTabFilter: View {
    @Binding var selectedTab: Tab
    let onTabChange: (Tab) -> Void
    
    private let tabs: [Tab] = [.all, .tech, .creative, .play, .apple, .jobs, .deals, .city, .qna, .hot]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        onTabChange(tab)
                    } label: {
                        Text(tab.displayName())
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedTab == tab ? Color.tintColor : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedTab == tab ? Color.clear : Color.secondaryText.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .forceClickable()
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color.bgColor)
    }
}

struct FeedTabFilter_Previews: PreviewProvider {
    @State static var selectedTab: Tab = .all
    
    static var previews: some View {
        FeedTabFilter(selectedTab: $selectedTab) { tab in
            selectedTab = tab
        }
    }
}