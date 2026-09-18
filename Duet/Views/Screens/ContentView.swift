//
//  ContentView.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-12-02.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            switch stepManager.currentStep {
            case .welcome:
                WelcomeView()
            case .pickOrientation:
                PickOrientationView()
            case .pickNameAndLanguage:
                PickNameAndLanguageView()
            case .createPlan:
                CreatePlanView()
            case .learnTogetherIntro:
                LearnTogetherIntroView()
            case .player1Translation:
                TranslationView(isPlayer1: true)
            case .player2Translation:
                TranslationView(isPlayer1: false)
            case .collaborativeLearningIntro:
                CollaborativeLearningIntroView()
            case .collaborativeLearning:
                CollaborativeLearningView()
            case .matchingGameIntro:
                MatchingGameIntroView()
            case .matchingGame:
                MatchingGameView()
            }
        }
        .background(colorScheme == .light ? Color("Cream") : Color("CharcoalMist"))
        .ignoresSafeArea(stepManager.currentStep == .createPlan ? .keyboard : [])
    }
}

enum Step: CaseIterable {
    case welcome, pickOrientation, pickNameAndLanguage, createPlan
    case learnTogetherIntro, player1Translation, player2Translation, collaborativeLearningIntro, collaborativeLearning, matchingGameIntro, matchingGame

    static let defaultStep: Self = .welcome

    var nextStep: Self {
        let allCases = Self.allCases
        guard let index = allCases.firstIndex(of: self), index < allCases.endIndex - 1 else { return .welcome }
        return allCases[index + 1]
    }
}

#Preview(traits: .portrait) {
    ContentView()
        .environment(StepManager())
        .preferredColorScheme(.dark)
}

#Preview(traits: .landscapeLeft) {
    ContentView()
        .environment(StepManager())
        .preferredColorScheme(.dark)
}
