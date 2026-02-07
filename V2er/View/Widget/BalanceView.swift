//
//  BalanceView.swift
//  V2er
//
//  Created by ghui on 2025/10/18.
//  Copyright © 2025 lessmore.io. All rights reserved.
//

import SwiftUI

struct BalanceView: View {
    var balance: BalanceInfo
    var size: CGFloat = 10

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            if balance.gold > 0 {
                BalanceBadge(count: balance.gold, icon: "🟡", color: .yellow, size: size)
            }
            if balance.silver > 0 {
                BalanceBadge(count: balance.silver, icon: "⚪️", color: .gray, size: size)
            }
            if balance.bronze > 0 {
                BalanceBadge(count: balance.bronze, icon: "🟤", color: .orange, size: size)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts: [String] = []
        if balance.gold > 0 { parts.append("\(balance.gold) gold") }
        if balance.silver > 0 { parts.append("\(balance.silver) silver") }
        if balance.bronze > 0 { parts.append("\(balance.bronze) bronze") }
        return "Balance: " + parts.joined(separator: ", ")
    }
}

struct BalanceBadge: View {
    var count: Int
    var icon: String
    var color: Color
    var size: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Text(icon)
                .font(.system(size: size - 1))
            Text("\(count)")
                .font(.system(size: size, weight: .medium))
                .foregroundColor(.primaryText)
        }
        .padding(.horizontal, Spacing.xxs)
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BalanceView(balance: BalanceInfo(gold: 47, silver: 28, bronze: 26))
            BalanceView(balance: BalanceInfo(gold: 100, silver: 0, bronze: 50))
            BalanceView(balance: BalanceInfo(gold: 0, silver: 10, bronze: 0))
        }
        .padding()
        .background(Color.itemBackground)
    }
}

// Extension to allow preview initialization
extension BalanceInfo {
    init(gold: Int, silver: Int, bronze: Int) {
        self.init()
        self.gold = gold
        self.silver = silver
        self.bronze = bronze
    }
}
