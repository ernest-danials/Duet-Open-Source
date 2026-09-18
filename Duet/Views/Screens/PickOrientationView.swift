//
//  PickOrientationView.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-12-02.
//

import SwiftUI

struct PickOrientationView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    
    var body: some View {
        TwoPlayersView { isLandscape in
            VStack {
                orientationInformation(isLandscape: isLandscape, isPlayerOne: true)
                
                Button {
                    stepManager.changeToNextStep()
                } label: {
                    Text("Next")
                        .customFont(.title2, weight: .semibold)
                        .padding(5)
                        .padding(.horizontal)
                }
                .buttonStyle(.glassProminent)
                .padding()
            }
        } player2View: { isLandscape in
            VStack {
                orientationInformation(isLandscape: isLandscape)
                
                Button {
                    stepManager.changeToNextStep()
                } label: {
                    Text("Next")
                        .customFont(.title2, weight: .semibold)
                        .padding(5)
                        .padding(.horizontal)
                }
                .buttonStyle(.glassProminent)
                .padding()
            }
        }
        .alignView(to: .center)
        .alignViewVertically(to: .center)
    }
    
    @ViewBuilder
    private func orientationInformation(isLandscape: Bool, isPlayerOne: Bool = false) -> some View {
        VStack(spacing: 8) {
            Image(systemName: isLandscape ? "arrow.up.and.person.rectangle.turn.right" : "arrow.up.and.person.rectangle.portrait")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .rotationEffect(.degrees(isLandscape ? 270 : 0))
                .scaleEffect(x: isLandscape && !isPlayerOne ? -1 : 1)

            VStack {
                Text("Are you sitting \(Text(isLandscape ? "side-by-side" : "face-to-face").bold().foregroundStyle(Color.accentColor)) with your partner?")
                    .customFont(.title3, weight: .semibold)
                    .multilineTextAlignment(.center)

                Text("If you are sitting \(isLandscape ? "face-to-face" : "side-by-side"), turn your device to \(isLandscape ? "portrait" : "landscape").")
                    .customFont(.body)
                    .multilineTextAlignment(.center)
            }

            Text("Orientation lock must be off")
                .customFont(.subheadline)
                .foregroundStyle(.primary.secondary)
        }
    }
}
