//
//  PronunciationGenerator.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-28.
//

import SwiftUI
import FoundationModels
import Observation

@Observable
@MainActor
final class PronunciationGenerator {
    private(set) var currentError: GenerationError?

    private var session: LanguageModelSession

    var isGenerating: Bool = false

    private static let systemPrompt = """
        Your job is to give a romanised pronunciation of the given word or sentence in the requested language.

        Return only the romanised pronunciation — no alternatives, no explanations, and no extra punctuation. For example, the romanised pronunciation of "사과" in Korean should return only "sa-gwa".

        Prefer the most common pronunciation. Your output must reflect how a native speaker would say it.
        """
    private let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)

    init() {
        self.session = LanguageModelSession(model: model) {
            Self.systemPrompt
        }
    }

    func generatePronunciation(of content: String, in language: Language) async -> String {
        guard !content.isEmpty, !isGenerating else { return "" }

        withAnimation {
            currentError = nil
            isGenerating = true
        }
        defer { withAnimation { isGenerating = false } }

        do {
            let result = try await self.session.respond {
                "Give the romanised pronunciation of the following \(language.rawValue): \(content)."
            }
            return result.content
        } catch let generationError as LanguageModelSession.GenerationError {
            switch generationError {
            case .exceededContextWindowSize:
                self.session = LanguageModelSession(model: model) {
                    Self.systemPrompt
                }
                
                withAnimation { self.currentError = .exceededContextWindowSize }
            case .assetsUnavailable:
                withAnimation { self.currentError = .assetsUnavailable }
            case .guardrailViolation:
                withAnimation { self.currentError = .guardrailViolation }
            case .unsupportedLanguageOrLocale:
                withAnimation { self.currentError = .unsupportedLanguageOrLocale }
            case .unsupportedGuide:
                withAnimation { self.currentError = .unsupportedGuide }
            case .decodingFailure:
                withAnimation { self.currentError = .decodingFailure }
            case .rateLimited:
                withAnimation { self.currentError = .rateLimited }
            case .concurrentRequests:
                withAnimation { self.currentError = .concurrentRequests }
            case .refusal:
                withAnimation { self.currentError = .refusal }
            default:
                withAnimation { self.currentError = .unknown }
            }
            return ""
        } catch {
            withAnimation { currentError = .unknown }
            return ""
        }
    }

    func prewarm() {
        session.prewarm()
    }
}
