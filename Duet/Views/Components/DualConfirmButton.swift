//
//  DualConfirmButton.swift
//  Duet
//

import SwiftUI

/// A button that requires both players to confirm before triggering a final action.
/// Shows the button until this player confirms, then shows "Waiting for your partner..."
/// until the other player confirms, at which point `onBothConfirmed` is called.
struct DualConfirmButton<Label: View>: View {
    let isConfirmed: Bool
    let hasOtherConfirmed: Bool
    var isDisabled: Bool = false
    let onConfirm: () -> Void
    let onBothConfirmed: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        if isConfirmed {
            Text("Waiting for your partner...")
                .customFont(.body, weight: .medium)
                .applyGlassEffect()
                .transition(.blurReplace)
                .onChange(of: hasOtherConfirmed) { _, newValue in
                    if newValue { onBothConfirmed() }
                }
        } else {
            Button {
                if hasOtherConfirmed {
                    onBothConfirmed()
                } else {
                    onConfirm()
                }
            } label: {
                label()
            }
            .buttonStyle(.glassProminent)
            .disabled(isDisabled)
            .transition(.blurReplace)
        }
    }
}
