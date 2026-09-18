//
//  GuidedLearningView.swift
//  Duet
//

import SwiftUI

struct CollaborativeLearningView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    @State private var currentIndex: Int = 0
    @State private var player1Confirmed: Bool = false
    @State private var player2Confirmed: Bool = false
    @State private var player1ShowingPartner: Bool = false
    @State private var player2ShowingPartner: Bool = false

    private var items: [LearningItem.PartiallyGenerated] { userInputManager.acceptedPlan?.items ?? [] }

    var body: some View {
        TwoPlayersView { isLandscape in
            playerCard(isPlayer1: true, isLandscape: isLandscape)
        } player2View: { isLandscape in
            playerCard(isPlayer1: false, isLandscape: isLandscape)
        }
    }

    @ViewBuilder
    private func playerCard(isPlayer1: Bool, isLandscape: Bool) -> some View {
        let item = items.isEmpty ? nil : items[currentIndex]
        let isShowingPartner = isPlayer1 ? player1ShowingPartner : player2ShowingPartner
        let partnerShowingMine = isPlayer1 ? player2ShowingPartner : player1ShowingPartner
        let isConfirmed = isPlayer1 ? player1Confirmed : player2Confirmed
        let hasOtherConfirmed = isPlayer1 ? player2Confirmed : player1Confirmed
        let isLastCard = currentIndex == items.count - 1

        VStack(spacing: 20) {
            if let item {
                VStack {
                    Text("\(currentIndex + 1) / \(items.count)")
                        .customFont(.callout)
                        .foregroundStyle(.secondary)

                    if let content = item.content {
                        Text(content)
                            .customFont(.title, weight: .bold)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.6)
                            .padding(.bottom, 50)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your translation to \((isPlayer1 ? userInputManager.player1Language : userInputManager.player2Language)?.rawValue ?? "your language")")
                            .customFont(.caption, weight: .semibold)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(translation(for: item, isPlayer1: isPlayer1))
                                .customFont(.title3, weight: .semibold)
                                .fixedSize(horizontal: false, vertical: true)
                                .minimumScaleFactor(0.6)

                            Text(pronunciation(for: item, isPlayer1: isPlayer1))
                                .customFont(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .alignView(to: .leading)

                    Divider().padding(.vertical)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Partner's translation to \((isPlayer1 ? userInputManager.player2Language : userInputManager.player1Language)?.rawValue ?? "their language")")
                            .customFont(.caption, weight: .semibold)
                            .foregroundStyle(.secondary)

                        if isShowingPartner {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(translation(for: item, isPlayer1: !isPlayer1))
                                    .customFont(.title3, weight: .semibold)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .minimumScaleFactor(0.6)
                                    .transition(.blurReplace)

                                Text(pronunciation(for: item, isPlayer1: !isPlayer1))
                                    .customFont(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .minimumScaleFactor(0.6)
                                    .transition(.blurReplace)
                            }
                        } else {
                            Text("Your partner hasn't revealed the translation yet")
                                .customFont(.body)
                                .foregroundStyle(.tertiary)
                                .transition(.blurReplace)
                        }
                    }
                    .alignView(to: .leading)
                }
                .frame(maxWidth: 500, maxHeight: 300)
                .padding(.vertical, 20)
                .applyGlassEffect(padding: 25)
                .id(currentIndex)
                .transition(.blurReplace)

                HStack {
                    Button {
                        withAnimation {
                            if isPlayer1 {
                                player2ShowingPartner.toggle()
                            } else {
                                player1ShowingPartner.toggle()
                            }
                        }
                    } label: {
                        Text(partnerShowingMine ? "Hide your translation from \(isPlayer1 ? userInputManager.player2Name : userInputManager.player1Name)" : "Reveal your translation to \(isPlayer1 ? userInputManager.player2Name : userInputManager.player1Name)")
                            .customFont(.title2, weight: .semibold)
                            .contentTransition(.numericText())
                            .padding(7)
                    }
                    .buttonStyle(.glass)

                    DualConfirmButton(isConfirmed: isConfirmed, hasOtherConfirmed: hasOtherConfirmed, onConfirm: {
                        withAnimation { if isPlayer1 { player1Confirmed = true } else { player2Confirmed = true } }
                    }, onBothConfirmed: {
                        withAnimation {
                            if isLastCard { stepManager.changeToNextStep() } else { currentIndex += 1 }
                            player1Confirmed = false
                            player2Confirmed = false
                            player1ShowingPartner = false
                            player2ShowingPartner = false
                        }
                    }) {
                        Text(isLastCard ? "Done" : "Next")
                            .customFont(.title2, weight: .semibold)
                            .padding(7)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func translation(for item: LearningItem.PartiallyGenerated, isPlayer1: Bool) -> String {
        isPlayer1 ? (userInputManager.userTranslationsByPlayer1[item.id] ?? "") : (userInputManager.userTranslationsByPlayer2[item.id] ?? "")
    }

    private func pronunciation(for item: LearningItem.PartiallyGenerated, isPlayer1: Bool) -> String {
        isPlayer1 ? (userInputManager.userPronunciationsByPlayer1[item.id] ?? "") : (userInputManager.userPronunciationsByPlayer2[item.id] ?? "")
    }
}
