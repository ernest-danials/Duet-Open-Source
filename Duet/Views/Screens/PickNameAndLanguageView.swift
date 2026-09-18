//
//  PickNameAndLanguageView.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-12-02.
//

import SwiftUI

struct PickNameAndLanguageView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    private let chatLines: [Int: String] = [
        1: "Hey, glad to meet you!",
        2: "My name is Duet.",
        3: "Pick your nickname!",
        5: "Thank you!",
        6: "What's your native language?",
        7: "This is the language you'll teach your partner.",
        9: "Great! Let's dive in."
    ]

    private let nicknames: [String] = [
        "Echo", "Glyph", "Lexis", "Lingua"
    ]

    @State private var currentAnimationNumber: Int = -1

    @State private var hasPlayer1ConfirmedName: Bool = false
    @State private var hasPlayer2ConfirmedName: Bool = false

    @State private var hasPlayer1ConfirmedLanguage: Bool = false
    @State private var hasPlayer2ConfirmedLanguage: Bool = false

    var body: some View {
        TwoPlayersView { isLandscape in
            content(isPlayer1: true)
        } player2View: { isLandscape in
            content(isPlayer1: false)
        }
        .alignView(to: .center)
        .alignViewVertically(to: .center)
        .task {
            $currentAnimationNumber.animate(from: 0, to: 4)
        }
        .onChange(of: self.currentAnimationNumber) { oldValue, newValue in
            if newValue == 9 {
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    self.stepManager.changeToNextStep(withAnimation: true)
                }
            }
        }
    }

    @ViewBuilder
    private func content(isPlayer1: Bool) -> some View {
        VStack {
            ChatBubbleListView(chatLines: chatLines, currentStep: currentAnimationNumber)
                .applyDefaultStyle()

            if currentAnimationNumber == 4 {
                nicknamePicker(isPlayer1: isPlayer1)
            }

            if currentAnimationNumber == 8 {
                languagePicker(isPlayer1: isPlayer1)
            }
        }
    }

    // MARK: - Nickname picker
    @ViewBuilder
    private func nicknamePicker(isPlayer1: Bool) -> some View {
        let hasPlayerConfirmedName = isPlayer1 ? hasPlayer1ConfirmedName : hasPlayer2ConfirmedName
        let hasOtherPlayerConfirmedName = isPlayer1 ? hasPlayer2ConfirmedName : hasPlayer1ConfirmedName
        let playerName = isPlayer1 ? userInputManager.player1Name : userInputManager.player2Name
        let otherPlayerName = isPlayer1 ? userInputManager.player2Name : userInputManager.player1Name

        if !hasPlayerConfirmedName {
            HStack(spacing: 8) {
                HStack {
                    ForEach(nicknames, id: \.self) { name in
                        PickerOptionButton(
                            label: name,
                            isSelected: playerName == name,
                            isTakenByOther: otherPlayerName == name
                        ) {
                            withAnimation {
                                if isPlayer1 {
                                    userInputManager.player1Name = name
                                } else {
                                    userInputManager.player2Name = name
                                }
                            }
                        }
                    }
                }

                Divider().frame(height: 15)

                DualConfirmButton(isConfirmed: hasPlayerConfirmedName, hasOtherConfirmed: hasOtherPlayerConfirmedName, isDisabled: playerName.isEmpty) {
                    withAnimation {
                        if isPlayer1 {
                            self.hasPlayer1ConfirmedName = true
                        } else {
                            self.hasPlayer2ConfirmedName = true
                        }
                    }
                } onBothConfirmed: {
                    $currentAnimationNumber.animate(from: 5, to: 8)
                } label: {
                    Text("Confirm")
                        .customFont(.callout, weight: .medium)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(.top, 5)
            .transition(.blurReplace)
        } else {
            Text("Waiting for your partner...")
                .customFont(.body, weight: .medium)
                .padding(.top, 5)
                .transition(.blurReplace)
        }
    }

    // MARK: - Language picker
    @ViewBuilder
    private func languagePicker(isPlayer1: Bool) -> some View {
        let hasPlayerConfirmedLanguage = isPlayer1 ? hasPlayer1ConfirmedLanguage : hasPlayer2ConfirmedLanguage
        let hasOtherPlayerConfirmedLanguage = isPlayer1 ? hasPlayer2ConfirmedLanguage : hasPlayer1ConfirmedLanguage
        let playerLanguage = isPlayer1 ? userInputManager.player1Language : userInputManager.player2Language
        let otherPlayerLanguage = isPlayer1 ? userInputManager.player2Language : userInputManager.player1Language

        let keyboardAvailable = playerLanguage?.isKeyboardAvailable ?? false
        let isConfirmDisabled = playerLanguage == nil || !keyboardAvailable

        if !hasPlayerConfirmedLanguage {
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    VStack {
                        HStack {
                            ForEach(Language.allCases.dropLast(2), id: \.self) { language in
                                PickerOptionButton(
                                    label: language.nameWithEmoji,
                                    isSelected: playerLanguage == language,
                                    isTakenByOther: otherPlayerLanguage == language
                                ) {
                                    guard otherPlayerLanguage != language else { return }

                                    withAnimation {
                                        if playerLanguage == language {
                                            if isPlayer1 {
                                                userInputManager.player1Language = nil
                                            } else {
                                                userInputManager.player2Language = nil
                                            }
                                        } else {
                                            if isPlayer1 {
                                                userInputManager.player1Language = language
                                            } else {
                                                userInputManager.player2Language = language
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        HStack {
                            ForEach(Language.allCases.dropFirst(2), id: \.self) { language in
                                PickerOptionButton(
                                    label: language.nameWithEmoji,
                                    isSelected: playerLanguage == language,
                                    isTakenByOther: otherPlayerLanguage == language
                                ) {
                                    guard otherPlayerLanguage != language else { return }

                                    withAnimation {
                                        if playerLanguage == language {
                                            if isPlayer1 {
                                                userInputManager.player1Language = nil
                                            } else {
                                                userInputManager.player2Language = nil
                                            }
                                        } else {
                                            if isPlayer1 {
                                                userInputManager.player1Language = language
                                            } else {
                                                userInputManager.player2Language = language
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Divider().frame(height: 15)

                    DualConfirmButton(isConfirmed: hasPlayerConfirmedLanguage, hasOtherConfirmed: hasOtherPlayerConfirmedLanguage, isDisabled: isConfirmDisabled) {
                        withAnimation {
                            if isPlayer1 {
                                self.hasPlayer1ConfirmedLanguage = true
                            } else {
                                self.hasPlayer2ConfirmedLanguage = true
                            }
                        }
                    } onBothConfirmed: {
                        $currentAnimationNumber.animate(from: 9, to: 9)
                    } label: {
                        Text("Confirm")
                            .customFont(.callout, weight: .medium)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .minimumScaleFactor(0.8)
                    }
                }

                if let language = playerLanguage, !keyboardAvailable {
                    Text("Add a \(language.rawValue) keyboard in Settings to continue")
                        .customFont(.footnote, weight: .regular)
                        .foregroundStyle(.secondary)
                        .transition(.blurReplace)
                        .padding(.top)
                }
            }
            .padding(.top, 5)
            .transition(.blurReplace)
        } else {
            Text("Waiting for your partner...")
                .customFont(.body, weight: .medium)
                .padding(.top, 5)
                .transition(.blurReplace)
        }
    }

}

// MARK: - PickerOptionButton
private struct PickerOptionButton: View {
    let label: String
    let isSelected: Bool
    let isTakenByOther: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .customFont(.footnote, weight: .semibold)
                        .foregroundStyle(Color.accentColor)
                        .transition(.symbolEffect(.drawOn).combined(with: .blurReplace))
                }

                Text(label)
                    .customFont(.callout, weight: .medium)
                    .foregroundStyle(isTakenByOther ? .secondary : .primary)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .buttonStyle(.glass)
        .disabled(isTakenByOther)
    }
}
