//
//  MatchingGameView.swift
//  Duet
//

import SwiftUI
import FoundationModels

private enum CardType {
    case english, player1, player2

    var color: Color {
        switch self {
        case .english: return Color("SoftBlush")
        case .player1: return Color("SageGreen")
        case .player2: return Color("RoseQuartz")
        }
    }
}

private struct MatchCard: Identifiable {
    let id = UUID()
    let itemId: GenerationID
    let cardType: CardType
    let mainText: String
    let subText: String?
}

struct MatchingGameView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    @State private var cards: [MatchCard] = []
    @State private var selectedCardIds: Set<UUID> = []
    @State private var currentItemId: GenerationID? = nil
    @State private var matchedItemIds: Set<GenerationID> = []
    @State private var wrongCardIds: Set<UUID> = []
    @State private var isGameComplete: Bool = false

    private var items: [LearningItem.PartiallyGenerated] { userInputManager.acceptedPlan?.items ?? [] }

    private var selectedCardTypes: Set<CardType> {
        Set(cards.filter { selectedCardIds.contains($0.id) }.map { $0.cardType })
    }

    var body: some View {
        GeometryReader { geo in
            if isGameComplete {
                completionView()
            } else {
                gameGrid(geo: geo)
            }
        }
        .transition(.blurReplace)
        .task { setupGame() }
    }

    private func setupGame() {
        var newCards: [MatchCard] = []
        for item in items {
            guard let content = item.content else { continue }

            newCards.append(MatchCard(itemId: item.id, cardType: .english, mainText: content, subText: nil))

            let player1Translation = userInputManager.userTranslationsByPlayer1[item.id] ?? ""
            let player1Pronunciation = userInputManager.userPronunciationsByPlayer1[item.id].flatMap { $0.isEmpty ? nil : $0 }
            newCards.append(MatchCard(itemId: item.id, cardType: .player1, mainText: player1Translation, subText: player1Pronunciation))

            let player2Translation = userInputManager.userTranslationsByPlayer2[item.id] ?? ""
            let player2Pronunciation = userInputManager.userPronunciationsByPlayer2[item.id].flatMap { $0.isEmpty ? nil : $0 }
            newCards.append(MatchCard(itemId: item.id, cardType: .player2, mainText: player2Translation, subText: player2Pronunciation))
        }
        cards = newCards.shuffled()
        selectedCardIds = []
        currentItemId = nil
        matchedItemIds = []
        wrongCardIds = []
        isGameComplete = false
    }

    // MARK: - Grid

    @ViewBuilder
    private func gameGrid(geo: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 280))], spacing: 12) {
                        ForEach(cards.filter { !matchedItemIds.contains($0.itemId) }) { card in
                            cardView(card, isLandscape: geo.isLandscape).transition(.blurReplace)
                        }
                    }
                    .padding()
                    .animation(.default, value: matchedItemIds)
                } header: {
                    remainingHeader()
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
    }

    @ViewBuilder
    private func remainingHeader() -> some View {
        let remaining = items.count - matchedItemIds.count
        let player1Language = userInputManager.player1Language?.rawValue ?? "Language 1"
        let player2Language = userInputManager.player2Language?.rawValue ?? "Language 2"
        HStack(spacing: 8) {
            Text("\(remaining)/\(items.count) \(remaining == 1 ? "Group" : "Groups") Remaining")
                .customFont(.title2, weight: .medium)
                .contentTransition(.numericText())
                .animation(.default, value: remaining)
                .applyGlassEffect()

            Text("Each group contains \(Text("English").foregroundStyle(selectedCardTypes.contains(.english) ? CardType.english.color : .primary)),  \(Text("\(player1Language)").foregroundStyle(selectedCardTypes.contains(.player1) ? CardType.player1.color : .primary)), and \(Text("\(player2Language)").foregroundStyle(selectedCardTypes.contains(.player2) ? CardType.player2.color : .primary))")
                .customFont(.title2, weight: .medium)
                .animation(.easeInOut(duration: 0.2), value: selectedCardTypes)
                .applyGlassEffect()
        }
        .padding(.bottom)
        .alignView(to: .leading)
        .padding(.horizontal)
    }

    // MARK: - Card

    @ViewBuilder
    private func cardView(_ card: MatchCard, isLandscape: Bool) -> some View {
        let isSelected = selectedCardIds.contains(card.id)
        let isWrong = wrongCardIds.contains(card.id)
        let isTypeDisabled = !isSelected && selectedCardTypes.contains(card.cardType)

        Button {
            tap(card)
        } label: {
            VStack(spacing: 4) {
                if !isLandscape {
                    VStack {
                        Text(card.mainText)
                            .customFont(.body, weight: .medium)
                            .foregroundStyle(isWrong ? .red : (isSelected ? Color.accentColor : Color.primary))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.6)

                        if let sub = card.subText {
                            Text(sub)
                                .customFont(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.gray)
                                .lineLimit(4)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .rotationEffect(.degrees(180))
                    
                    Divider()
                        .padding(.vertical, 5)
                }
                
                VStack(spacing: 4) {
                    Text(card.mainText)
                        .customFont(.body, weight: .medium)
                        .foregroundStyle(isWrong ? .red : (isSelected ? Color.accentColor : Color.primary))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                    
                    if let sub = card.subText {
                        Text(sub)
                            .customFont(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                            .lineLimit(4)
                            .minimumScaleFactor(0.6)
                    }
                }
            }
            .alignView(to: .center)
            .padding(15)
            .frame(minWidth: 100, minHeight: 100)
            .applyGlassEffect(isInteractive: true)
        }
        .disabled(isTypeDisabled)
        .opacity(isTypeDisabled ? 0.35 : 1)
        .animation(.easeInOut(duration: 0.2), value: isTypeDisabled)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isWrong)
        .padding(5)
    }

    // MARK: - Game Logic

    private func tap(_ card: MatchCard) {
        guard wrongCardIds.isEmpty, !matchedItemIds.contains(card.itemId) else { return }

        if selectedCardIds.contains(card.id) {
            withAnimation {
                selectedCardIds.remove(card.id)
                if selectedCardIds.isEmpty { currentItemId = nil }
            }
            return
        }

        if let current = currentItemId, current != card.itemId {
            var wrong = selectedCardIds
            wrong.insert(card.id)
            withAnimation { wrongCardIds = wrong }
            Task {
                try? await Task.sleep(nanoseconds: 700_000_000)
                withAnimation { wrongCardIds = []; selectedCardIds = []; currentItemId = nil }
            }
            return
        }

        withAnimation {
            selectedCardIds.insert(card.id)
            currentItemId = card.itemId
        }

        let groupSize = cards.filter { $0.itemId == card.itemId }.count
        if selectedCardIds.count == groupSize {
            withAnimation {
                matchedItemIds.insert(card.itemId)
                selectedCardIds = []
                currentItemId = nil
            }
            if !items.isEmpty && matchedItemIds.count == items.count {
                withAnimation(.default.delay(0.4)) { isGameComplete = true }
            }
        }
    }

    // MARK: - Completion View

    @ViewBuilder
    private func completionView() -> some View {
        VStack(spacing: 24) {
            Text("🎉")
                .font(.system(size: 80))

            Text("You did it!")
                .customFont(.largeTitle, weight: .bold)

            Text("\(userInputManager.player1Name) and \(userInputManager.player2Name) matched every group!")
                .customFont(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button {
                    withAnimation { setupGame() }
                } label: {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .customFont(.title2, weight: .semibold)
                        .padding(8)
                }
                .buttonStyle(.glass)

                Button {
                    stepManager.changeToNextStep()
                } label: {
                    Label("Finish", systemImage: "checkmark")
                        .customFont(.title2, weight: .semibold)
                        .padding(8)
                }
                .buttonStyle(.glassProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    MatchingGameView()
        .preferredColorScheme(.dark)
        .background(Color("CharcoalMist"))
        .environment(StepManager())
        .environment(\.userInputManager, UserInputManager.preview)
}
