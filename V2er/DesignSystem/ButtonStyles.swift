//
//  ButtonStyles.swift
//  V2er
//
//  Design token: reusable ButtonStyle conformances.
//

import SwiftUI

/// Filled accent-background button (Login, Post, Reply).
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.accentColor.opacity(isEnabled ? 1 : 0.4))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}

/// Bordered outline button (Register, secondary actions).
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(Color.accentColor.opacity(isEnabled ? 1 : 0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Color.accentColor.opacity(isEnabled ? 1 : 0.4), lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}

/// Pill-shaped button with tinted background (Checkin, tag actions).
struct CapsuleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.accentColor.opacity(isEnabled ? 1 : 0.4))
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.accentColor.opacity(isEnabled ? 0.12 : 0.06))
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}
