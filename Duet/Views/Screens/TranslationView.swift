//
//  TranslationView.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-28.
//

import SwiftUI
import FoundationModels

struct TranslationView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    @State private var translationGenerator: TranslationGenerator?
    @State private var pronunciationGenerator: PronunciationGenerator?

    let isPlayer1: Bool

    @State private var isHighlightingEmptyTranslations: Bool = false
    @State private var translationGeneratingItemId: GenerationID?
    @State private var pronunciationGeneratingItemId: GenerationID?

    private var language: Language {
        if isPlayer1 {
            self.userInputManager.player1Language ?? .korean
        } else {
            self.userInputManager.player2Language ?? .chinese
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                if let plan = self.userInputManager.acceptedPlan, let items = plan.items {
                    LazyVStack(pinnedViews: .sectionHeaders) {
                        Section {
                            ForEach(items) { item in
                                itemRow(item)
                                    .id(item.id)
                            }
                        } header: {
                            playerInfo()
                        }
                    }
                    .safeAreaPadding()
                }
            }
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                if let plan = self.userInputManager.acceptedPlan, let items = plan.items {
                    Button {
                        let incomplete = userInputManager.isUserTranslationsIncomplete(for: items, forPlayer1: isPlayer1) ||
                                         userInputManager.isUserPronunciationsIncomplete(for: items, forPlayer1: isPlayer1)
                        if incomplete {
                            withAnimation {
                                self.isHighlightingEmptyTranslations = true

                                if let firstEmptyID = items.first(where: {
                                    userInputManager.isUserTranslationEmpty(for: $0, forPlayer1: isPlayer1) ||
                                    userInputManager.isUserPronunciationEmpty(for: $0, forPlayer1: isPlayer1)
                                })?.id {
                                    scrollProxy.scrollTo(firstEmptyID)
                                }
                            }
                        } else {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            stepManager.changeToNextStep()
                        }
                    } label: {
                        Label(isPlayer1 ? "Done, I will hand the iPad to \(self.userInputManager.player2Name)" : "Done", systemImage: "checkmark")
                            .customFont(.title2, weight: .semibold)
                            .padding(8)
                    }
                    .buttonStyle(.glassProminent)
                    .padding()
                }
            }
        }
        .transition(.blurReplace)
        .task {
            translationGenerator = TranslationGenerator()
            pronunciationGenerator = PronunciationGenerator()
            
            translationGenerator?.prewarm()
            pronunciationGenerator?.prewarm()
        }
    }

    // MARK: - Functions for View
    @ViewBuilder
    private func itemRow(_ item: LearningItem.PartiallyGenerated) -> some View {
        VStack {
            HStack {
                itemCard(item)
                    .alignViewVertically(to: .top)

                VStack(alignment: .leading, spacing: 5) {
                    Text(promptText(for: item))
                        .customFont(.headline, weight: .semibold)
                        .padding(.leading)

                    translationField(for: item)

                    Button {
                        Task {
                            withAnimation { self.translationGeneratingItemId = item.id }
                            let translation = await translationGenerator?.generateTranslation(of: item, to: language)
                            try? await Task.sleep(nanoseconds: 600_000_000)
                            userInputManager.updateUserTranslation(to: translation ?? "", for: item, forPlayer1: isPlayer1)
                            withAnimation { self.translationGeneratingItemId = nil }
                        }
                    } label: {
                        Label(translationGeneratingItemId == item.id ? "Translating..." : "Ask Duet for help", systemImage: "sparkles")
                            .customFont(.body, weight: .medium)
                            .foregroundStyle(Color.accentColor)
                            .padding(5)
                    }
                    .buttonStyle(.glass)
                    .disabled(self.translationGenerator?.isGenerating ?? false)

                    Text("How would you pronounce this?")
                        .customFont(.headline, weight: .semibold)
                        .padding(.leading)
                        .padding(.top)

                    pronunciationField(for: item)

                    let translationEmpty = userInputManager.isUserTranslationEmpty(for: item, forPlayer1: isPlayer1)

                    Button {
                        Task {
                            withAnimation { self.pronunciationGeneratingItemId = item.id }
                            let translationText = userInputManager.translationBinding(for: item, forPlayer1: isPlayer1).wrappedValue
                            let pronunciation = await pronunciationGenerator?.generatePronunciation(of: translationText, in: language)
                            try? await Task.sleep(nanoseconds: 600_000_000)
                            userInputManager.updateUserPronunciation(to: pronunciation ?? "", for: item, forPlayer1: isPlayer1)
                            withAnimation { self.pronunciationGeneratingItemId = nil }
                        }
                    } label: {
                        Label(pronunciationGeneratingItemId == item.id ? "Writing pronunciation..." : "Ask Duet for help", systemImage: "sparkles")
                            .customFont(.body, weight: .medium)
                            .foregroundStyle(translationEmpty ? .secondary : Color.accentColor)
                            .padding(5)
                    }
                    .buttonStyle(.glass)
                    .disabled(translationEmpty || (self.pronunciationGenerator?.isGenerating ?? false))
                    
                    Text("\(translationEmpty ? "Enter your translation above first. " : "")Duet is powered by Apple Intelligence and can make mistakes.")
                        .customFont(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                        .transition(.blurReplace)
                }
                .padding(.leading, 5)
            }
            .alignView(to: .leading)

            Divider()
                .padding(.vertical, 25)
        }
    }

    @ViewBuilder
    private func itemCard(_ item: LearningItem.PartiallyGenerated) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 2) {
                if let type = item.type {
                    Text(type.rawValue)
                        .customFont(.callout)
                        .foregroundStyle(.primary.secondary)
                }

                if let content = item.content {
                    Text(content)
                        .customFont(.title3, weight: .medium)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let rationale = item.rationale {
                Text(rationale)
                    .customFont(.subheadline)
                    .foregroundStyle(.primary.secondary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.6)
            }
        }
        .frame(width: 300, alignment: .leading)
        .applyGlassEffect()
    }

    private func promptText(for item: LearningItem.PartiallyGenerated) -> String {
        if let type = item.type {
            switch type {
            case .word:
                return "How would you say '\(item.content?.lowercased() ?? "this")' in \(language.rawValue)?"
            case .sentence:
                return "How would you say this sentence in \(language.rawValue)?"
            }
        } else {
            return "How would you say this in \(language.rawValue)?"
        }
    }

    @ViewBuilder
    private func translationField(for item: LearningItem.PartiallyGenerated) -> some View {
        HStack {
            TextField(text: self.userInputManager.translationBinding(for: item, forPlayer1: isPlayer1)) {
                Text("Enter your translation for this \(item.type?.rawValue.lowercased() ?? "")")
                    .foregroundStyle((userInputManager.isUserTranslationEmpty(for: item, forPlayer1: isPlayer1) && isHighlightingEmptyTranslations) ? .red : .secondary)
            }
            .customFont(.body)

            Button {
                self.userInputManager.resetUserTranslation(for: item, forPlayer1: isPlayer1)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .disabled(self.userInputManager.isUserTranslationEmpty(for: item, forPlayer1: isPlayer1))
            .opacity(self.userInputManager.isUserTranslationEmpty(for: item, forPlayer1: isPlayer1) ? 0.0 : 1.0)
        }
        .applyGlassEffect(isInteractive: true)
    }

    @ViewBuilder
    private func pronunciationField(for item: LearningItem.PartiallyGenerated) -> some View {
        HStack {
            TextField(text: self.userInputManager.pronunciationBinding(for: item, forPlayer1: isPlayer1)) {
                Text("Enter your pronunciation for this \(item.type?.rawValue.lowercased() ?? "") (e.g. sa-gwa)")
                    .foregroundStyle((userInputManager.isUserPronunciationEmpty(for: item, forPlayer1: isPlayer1) && isHighlightingEmptyTranslations) ? .red : .secondary)
            }
            .customFont(.body)

            Button {
                self.userInputManager.resetUserPronunciation(for: item, forPlayer1: isPlayer1)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .disabled(self.userInputManager.isUserPronunciationEmpty(for: item, forPlayer1: isPlayer1))
            .opacity(self.userInputManager.isUserPronunciationEmpty(for: item, forPlayer1: isPlayer1) ? 0.0 : 1.0)
        }
        .applyGlassEffect(isInteractive: true)
    }

    @ViewBuilder
    private func playerInfo() -> some View {
        HStack(spacing: 8) {
            var playerName: String {
                if isPlayer1 {
                    return language.emoji + " " + userInputManager.player1Name
                } else {
                    return language.emoji + " " + userInputManager.player2Name
                }
            }
            
            Text(playerName)
                .customFont(.title, weight: .semibold)
                .applyGlassEffect()

            if let error = translationGenerator?.currentError ?? pronunciationGenerator?.currentError {
                Label(error.message, systemImage: "exclamationmark.triangle.fill")
                    .customFont(.body, weight: .semibold)
                    .foregroundStyle(.red)
                    .applyGlassEffect()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .transition(.blurReplace)
            }
        }
        .padding(.bottom)
        .alignView(to: .leading)
    }
}
