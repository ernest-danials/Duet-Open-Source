//
//  File.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-08.
//

import SwiftUI
import Observation

@Observable
final class StepManager {
    private(set) var currentStep: Step = .defaultStep

    func changeStep(_ step: Step, shouldUseAnimation: Bool = true) {
        if shouldUseAnimation {
            withAnimation {
                self.currentStep = step
            }
        } else {
            self.currentStep = step
        }
    }
    
    func changeToNextStep(withAnimation: Bool = true) {
        changeStep(self.currentStep.nextStep, shouldUseAnimation: withAnimation)
    }
}

private struct StepManagerKey: EnvironmentKey {
    static let defaultValue = StepManager()
}

extension EnvironmentValues {
    var stepManager: StepManager {
        get { self[StepManagerKey.self] }
        set { self[StepManagerKey.self] = newValue }
    }
}
