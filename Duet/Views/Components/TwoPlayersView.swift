//
//  TwoPlayersView.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-12-02.
//

import SwiftUI

struct TwoPlayersView<V1: View, V2: View>: View {
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    @ViewBuilder let player1View: (_ isLandscape: Bool) -> V1
    @ViewBuilder let player2View: (_ isLandscape: Bool) -> V2

    var body: some View {
        GeometryReader { geo in
            if geo.isLandscape {
                HStack(spacing: 0) {
                    player2View(true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .topLeading) {
                            playerOverlay(language: userInputManager.player2Language, name: userInputManager.player2Name)
                        }

                    Divider().padding(.vertical)
                    
                    player1View(true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .topLeading) {
                            playerOverlay(language: userInputManager.player1Language, name: userInputManager.player1Name)
                        }
                }.transition(.blurReplace)
            } else {
                VStack(spacing: 0) {
                    player2View(false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .topLeading) {
                            playerOverlay(language: userInputManager.player2Language, name: userInputManager.player2Name)
                        }
                        .rotationEffect(.degrees(180))

                    Divider().padding(.horizontal)

                    player1View(false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .topLeading) {
                            playerOverlay(language: userInputManager.player1Language, name: userInputManager.player1Name)
                        }
                }.transition(.blurReplace)
            }
        }
        .transition(.blurReplace)
    }
    
    @ViewBuilder
    private func playerOverlay(language: Language?, name: String) -> some View {
        if let language, !name.isEmpty {
            Text(language.emoji + " " + name)
                .customFont(.body, weight: .medium)
                .applyGlassEffect()
                .padding()
                .transition(.blurReplace)
        }
    }
}
