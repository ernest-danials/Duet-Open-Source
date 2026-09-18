//
//  MatchingGameIntroView.swift
//  Duet
//

import SwiftUI

struct MatchingGameIntroView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    private var chatLines: [Int:String] {[
        1:"Well done on the collaborative learning!",
        2:"Now it's time for the matching game.",
        3:"Here's how it works.",
        5:"You'll see a board of shuffled cards.",
        6:"Each card shows either the English word, \(userInputManager.player1Language?.rawValue ?? "") translation, or \(userInputManager.player2Language?.rawValue ?? "")'s translation.",
        8:"Tap cards that belong to the same word to group them together.",
        9:"Wrong guesses will flash red and reset, so think carefully!",
        11:"Work together to match every group.",
        13:"Ready to play?"
    ]}

    @State private var currentAnimationNumber: Int = -1

    @State private var hasPlayer1Confirmed: Bool = false
    @State private var hasPlayer2Confirmed: Bool = false

    var body: some View {
        TwoPlayersView { isLandscape in
            content(isPlayer1: true)
        } player2View: { isLandscape in
            content(isPlayer1: false)
        }
        .alignView(to: .center)
        .alignViewVertically(to: .center)
        .task {
            $currentAnimationNumber.animate(from: 1, to: 14, skip: [4, 7, 10, 12])
        }
    }

    @ViewBuilder
    private func content(isPlayer1: Bool) -> some View {
        let hasPlayerConfirmed = isPlayer1 ? hasPlayer1Confirmed : hasPlayer2Confirmed
        let hasOtherConfirmed = isPlayer1 ? hasPlayer2Confirmed : hasPlayer1Confirmed

        VStack {
            ChatBubbleListView(chatLines: chatLines, currentStep: currentAnimationNumber, windowSize: 13)
                .applyDefaultStyle()

            if currentAnimationNumber >= 14 {
                DualConfirmButton(isConfirmed: hasPlayerConfirmed, hasOtherConfirmed: hasOtherConfirmed) {
                    withAnimation {
                        if isPlayer1 {
                            hasPlayer1Confirmed = true
                        } else {
                            hasPlayer2Confirmed = true
                        }
                    }
                } onBothConfirmed: {
                    stepManager.changeToNextStep()
                } label: {
                    Text("Let's go!")
                        .customFont(.title2, weight: .semibold)
                        .padding(5)
                        .padding(.horizontal)
                }
                .padding(.top, 6)
                .transition(.blurReplace)
            }
        }
    }
}
