//
//  CreatePlanView.swift
//  Duet
//

import SwiftUI
import FoundationModels

struct CreatePlanView: View {
    @Environment(\.stepManager) private var stepManager: StepManager
    @Environment(\.userInputManager) private var userInputManager: UserInputManager

    @State private var planGenerator: PlanGenerator?

    private var chatLines: [Int:String] {[
        1:"Now, let's build a plan together.",
        2:"Think about what you'd like to learn to say in your partner's language.",
        3:"Ordering food, greeting locals, making small talk — anything!",
        4:"Talk it over with your partner, then describe your idea.",
        5:"Ready to tell me?",
        7:"Great idea! Let me create a learning plan for you and your partner.",
        9:planGenerator?.currentError == nil ? (planGenerator?.plan?.rationale ?? "Creating plan...") : "Something went wrong. Let's try again!",
        10:"What a great plan. I'm excited to see how it goes!"
    ]}

    private let planDescriptionCharacterLimit = 200

    @State private var currentAnimationNumber: Int = -1

    @State private var hasPlayer1Ready: Bool = false
    @State private var hasPlayer2Ready: Bool = false

    @State private var hasPlayer1Accepted: Bool = false
    @State private var hasPlayer2Accepted: Bool = false

    var body: some View {
        TwoPlayersView { isLandscape in
            VStack(spacing: 10) {
                content(isLandscape: isLandscape, isPlayer1: true)
                
                if currentAnimationNumber == 5 {
                    readyButton(isPlayer1: true)
                }
            }
        } player2View: { isLandscape in
            VStack(spacing: 10) {
                content(isLandscape: isLandscape, isPlayer1: false)
                
                if currentAnimationNumber == 5 {
                    readyButton(isPlayer1: false)
                }
            }
        }
        .alignView(to: .center)
        .alignViewVertically(to: .center)
        .opacity(currentAnimationNumber == 6 ? 0.5 : 1.0)
        .blur(radius: currentAnimationNumber == 6 ? 5.0 : 0.0)
        .overlay {
            if currentAnimationNumber == 6 {
                TextInputOverlay(text: Bindable(userInputManager).planDescription, title: "What would you like to learn to say in each other's language?", placeholder: "Describe your plan", characterLimit: planDescriptionCharacterLimit) {
                    planGenerator?.reset()
                    $currentAnimationNumber.animate(from: 7, to: 9)
                }
            }
        }
        .onChange(of: self.currentAnimationNumber) { _, newValue in
            if newValue == 8 {
                generatePlan()
            } else if newValue == 10 {
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    self.stepManager.changeToNextStep(withAnimation: true)
                }
            }
        }
        .task {
            setUpPlanGenerator()
            $currentAnimationNumber.animate(from: 1, to: 5)
        }
    }
    
    private func content(isLandscape: Bool, isPlayer1: Bool) -> some View {
        let layout = isLandscape ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(alignment: .bottom))
        let hasPlayerAccepted = isPlayer1 ? hasPlayer1Accepted : hasPlayer2Accepted
        let hasOtherPlayerAccepted = isPlayer1 ? hasPlayer2Accepted : hasPlayer1Accepted
        
        return layout {
            ChatBubbleListView(chatLines: chatLines, currentStep: currentAnimationNumber)
                .applyDefaultStyle()
            
            if currentAnimationNumber == 8 || currentAnimationNumber == 9 {
                VStack(alignment: .leading) {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            if let error = planGenerator?.currentError {
                                ContentUnavailableView("Error Creating Plan", systemImage: "exclamationmark.octagon.fill", description: Text(error.message))
                                    .transition(.blurReplace)
                            } else if let plan = planGenerator?.plan, planGenerator?.currentError == nil {
                                GeneratedPlanCardContent(plan: plan)
                            }
                        }
                        .scrollIndicators(.hidden)
                        .scrollBounceBehavior(.basedOnSize)
                        .onChange(of: planGenerator?.plan?.items) { _, newValue in
                            withAnimation(.smooth) {
                                scrollProxy.scrollTo(newValue?.last?.id)
                            }
                        }
                    }
                    .alignView(to: .leading)
                    .safeAreaInset(edge: .bottom, alignment: .trailing) {
                        VStack(alignment: .trailing) {
                            if !(planGenerator?.isGenerating ?? false) {
                                Button {
                                    hasPlayer1Accepted = false
                                    hasPlayer2Accepted = false
                                    $currentAnimationNumber.animate(from: 6, to: 6)
                                } label: {
                                    Label("Retry", systemImage: "arrow.counterclockwise")
                                        .customFont(.body)
                                        .foregroundStyle(Color.accentColor)
                                        .padding(3)
                                }
                                .buttonStyle(.glass)
                                .transition(.blurReplace)
                                
                                if planGenerator?.plan != nil && planGenerator?.currentError == nil {
                                    DualConfirmButton(isConfirmed: hasPlayerAccepted, hasOtherConfirmed: hasOtherPlayerAccepted) {
                                        withAnimation {
                                            if isPlayer1 {
                                                hasPlayer1Accepted = true
                                            } else {
                                                hasPlayer2Accepted = true
                                            }
                                        }
                                    } onBothConfirmed: {
                                        userInputManager.acceptedPlan = planGenerator?.plan
                                        planGenerator?.reset(startNewSession: true)
                                        $currentAnimationNumber.animate(from: 10, to: 10)
                                    } label: {
                                        Label("Accept", systemImage: "checkmark")
                                            .customFont(.body, weight: .medium)
                                            .padding(3)
                                    }
                                }
                            }
                        }
                        .animation(.smooth, value: planGenerator?.isGenerating)
                    }
                    .frame(maxWidth: 400, maxHeight: 450)
                    .applyGlassEffect(padding: 25)
                    .transition(.blurReplace)
                    
                    Text("Duet is powered by Apple Intelligence and can make mistakes.")
                        .customFont(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.leading)
                        .transition(.blurReplace)
                }
            }
        }
    }
    
    @ViewBuilder
    private func readyButton(isPlayer1: Bool) -> some View {
        let hasPlayerReady = isPlayer1 ? hasPlayer1Ready : hasPlayer2Ready
        let hasOtherPlayerReady = isPlayer1 ? hasPlayer2Ready : hasPlayer1Ready
        
        DualConfirmButton(isConfirmed: hasPlayerReady, hasOtherConfirmed: hasOtherPlayerReady) {
            withAnimation {
                if isPlayer1 {
                    hasPlayer1Ready = true
                } else {
                    hasPlayer2Ready = true
                }
            }
        } onBothConfirmed: {
            $currentAnimationNumber.animate(from: 6, to: 6)
        } label: {
            Text("Ready")
                .customFont(.title3, weight: .semibold)
                .padding(5)
                .padding(.horizontal)
        }
        .padding(.top, 5)
        .transition(.blurReplace)
    }

    private func generatePlan() {
        Task {
            await planGenerator?.generatePlan(userRequest: userInputManager.planDescription)
        }
    }

    private func setUpPlanGenerator() {
        self.planGenerator = PlanGenerator()
        self.planGenerator?.prewarm()
    }
}
