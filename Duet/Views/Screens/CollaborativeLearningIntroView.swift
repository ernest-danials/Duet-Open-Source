//
//  CollaborativeLearningIntroView.swift
//  Duet
//

import SwiftUI

struct CollaborativeLearningIntroView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    private var chatLines: [Int:String] {[
        1:"Great work, both of you!",
        2:"You've each translated the words into your own language.",
        3:"Now it's time to exchange your languages and teach each other.",
        5:"You'll go through each word and sentence together, one at a time.",
        6:"Each of you will see the English word and your own translation.",
        8:"When you're ready, reveal your translation to your partner.",
        9:"Teach them how to say it too. Pronunciation matters!",
        11:"Once you both feel confident with the word, move on to the next.",
        13:"This phase is all yours. Take as long as you need.",
        14:"Are you ready to learn together with your partner?"
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
            $currentAnimationNumber.animate(from: 1, to: 15, skip: [4, 7, 10, 12])
        }
    }

    @ViewBuilder
    private func content(isPlayer1: Bool) -> some View {
        let hasPlayerConfirmed = isPlayer1 ? hasPlayer1Confirmed : hasPlayer2Confirmed
        let hasOtherConfirmed = isPlayer1 ? hasPlayer2Confirmed : hasPlayer1Confirmed

        VStack {
            ChatBubbleListView(chatLines: chatLines, currentStep: currentAnimationNumber, windowSize: 13)
                .applyDefaultStyle()

            if currentAnimationNumber >= 15 {
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
