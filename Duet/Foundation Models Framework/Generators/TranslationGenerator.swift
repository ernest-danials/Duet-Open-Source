//
//  File.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-28.
//

import SwiftUI
import FoundationModels
import Observation

@Observable
@MainActor
final class TranslationGenerator {
    private(set) var currentError: GenerationError?
    
    private var session: LanguageModelSession
    
    var isGenerating: Bool = false
    
    private static let systemPrompt = """
        Your job is to translate the given word or sentence into the requested language.

        Return only the translation — no alternatives, no explanations, and no extra punctuation. For example, translating "apple" to Korean should return only "사과".

        Prefer the most common, general-purpose translation. Your output must sound natural to a native speaker.
        """
    private let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
    
    init() {
        self.session = LanguageModelSession(model: model) {
            Self.systemPrompt
        }
    }
    
    func generateTranslation(of item: LearningItem.PartiallyGenerated, to language: Language) async -> String {
        guard let content = item.content, !isGenerating else { return "" }

        withAnimation {
            currentError = nil
            isGenerating = true
        }
        defer { withAnimation { isGenerating = false } }

        do {
            let translation = try await self.session.respond {
                "Translate the following to \(language.rawValue): \(content)."
            }
            return translation.content
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
