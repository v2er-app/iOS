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
        HStack(spacing: Spacing.sm) {
            if balance.gold > 0 {
                BalanceBadge(count: balance.gold, kind: .gold, size: size)
            }
            if balance.silver > 0 {
                BalanceBadge(count: balance.silver, kind: .silver, size: size)
            }
            if balance.bronze > 0 {
                BalanceBadge(count: balance.bronze, kind: .bronze, size: size)
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
    var kind: CoinKind
    var size: CGFloat

    enum CoinKind {
        case gold, silver, bronze

        var gradient: LinearGradient {
            switch self {
            case .gold:
                return LinearGradient(
                    colors: [Color(red: 1.0, green: 0.84, blue: 0.3),
                             Color(red: 0.9, green: 0.68, blue: 0.1)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            case .silver:
                return LinearGradient(
                    colors: [Color(red: 0.82, green: 0.84, blue: 0.86),
                             Color(red: 0.68, green: 0.7, blue: 0.73)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            case .bronze:
                return LinearGradient(
                    colors: [Color(red: 0.80, green: 0.56, blue: 0.32),
                             Color(red: 0.62, green: 0.40, blue: 0.20)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        }

        var shadow: Color {
            switch self {
            case .gold: return Color(red: 0.9, green: 0.68, blue: 0.1).opacity(0.4)
            case .silver: return Color.gray.opacity(0.3)
            case .bronze: return Color(red: 0.62, green: 0.40, blue: 0.20).opacity(0.3)
            }
        }
    }

    var body: some View {
        HStack(spacing: size * 0.3) {
            // Coin circle with gradient
            Circle()
                .fill(kind.gradient)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: size * 0.08)
                )
                .shadow(color: kind.shadow, radius: 1, y: 0.5)

            Text("\(count)")
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundColor(.primaryText)
        }
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BalanceView(balance: BalanceInfo(gold: 47, silver: 28, bronze: 26))
            BalanceView(balance: BalanceInfo(gold: 47, silver: 28, bronze: 26), size: 13)
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
