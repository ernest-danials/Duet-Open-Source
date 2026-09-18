//
//  LearnTogetherIntroView.swift
//  Duet
//

import SwiftUI

struct LearnTogetherIntroView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    private var chatLines: [Int:String] {[
        1:"Now that we have a plan,",
        2:"It's time for you to teach your partner.",
        3:"Here's how it will go.",
        5:"Firstly, each of you will have your own time to translate all the English words from the plan.",
        6:"You'll do this one by one. We'll start with \(self.userInputManager.player1Name).",
        8:"Secondly, you will have a time to teach your partner.",
        9:"You'll use your translations here!",
        11:"Finally, we'll finish off with a quick collaborative matching-game.",
        13:"Sounds good? I'm ready when you are!"
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
                    Text(isPlayer1 ? "Ready!" : "Ready! I will wait for \(userInputManager.player1Name) to finish")
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
