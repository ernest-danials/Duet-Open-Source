//
//  File.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-25.
//

import SwiftUI
import FoundationModels
import Observation

@Observable
@MainActor
final class PlanGenerator {
    private(set) var plan: Plan.PartiallyGenerated?
    private(set) var currentError: GenerationError?
    
    private var session: LanguageModelSession
    
    var isGenerating: Bool {
        return session.isResponding
    }
    
    private static let systemPrompt = """
        Your job is to create a language-learning plan in English for two users who are learning each other's native languages together. Your job is to present a learning plan, not actually teaching.

        A plan contains a list of English words and sentences. Do not mention that your plan is in English explicitly. The two users will translate each English item into their own native language to teach the other person. Therefore, your content MUST be completely understandable by both users with different first languages, which means the content MUST NOT require prior knowledge of either language.

        Choose content that is practical, natural, appropriate, and related to the user's request. Prefer everyday vocabulary and phrases over abstract or academic ones. Refrain from using proper nouns. Default to beginner-friendly content unless the user specifies otherwise.

        A plan must contain multiple words and a few sentences. Words are the main focus and must lead naturally to the sentences at the end. The sentences must not introduce too many new word. List all the sentences together and the very end.

        Here is an example for your reference:
        """

    init() {
        self.session = LanguageModelSession {
            Self.systemPrompt
            Plan.example
        }
    }
    
    func generatePlan(userRequest: String) async {
        guard !userRequest.isEmpty && !isGenerating else { return }
        
        currentError = nil

        do {
            let stream = self.session.streamResponse(generating: Plan.self) {
                "Generate a plan with the following user request: \(userRequest)."
            }

            for try await partialPlan in stream {
                withAnimation {
                    self.plan = partialPlan.content
                }
            }
        } catch let generationError as LanguageModelSession.GenerationError {
            switch generationError {
            case .refusal:
                self.currentError = .refusal
            case .assetsUnavailable:
                self.currentError = .assetsUnavailable
            case .decodingFailure:
                self.currentError = .decodingFailure
            case .exceededContextWindowSize:
                self.session = LanguageModelSession {
                    Self.systemPrompt
                    Plan.example
                }
                
                self.currentError = .exceededContextWindowSize
            case .guardrailViolation:
                self.currentError = .guardrailViolation
            case .rateLimited:
                self.currentError = .rateLimited
            case .concurrentRequests:
                self.currentError = .concurrentRequests
            case .unsupportedLanguageOrLocale:
                self.currentError = .unsupportedLanguageOrLocale
            case .unsupportedGuide:
                self.currentError = .unsupportedGuide
            default:
                self.currentError = .unknown
            }
        } catch {
            self.currentError = .unknown
        }
    }
    
    func reset(startNewSession: Bool = false) {
        plan = nil
        currentError = nil
        
        if startNewSession {
            self.session = LanguageModelSession {
                Self.systemPrompt
                Plan.example
            }
        }
    }
    
    func prewarm() {
        session.prewarm()
    }
}

extension Plan {
    static let example: Self = .init(
        emoji: "🍽️",
        title: "Dining Out",
        description: "Essential words and phrases for ordering food at a restaurant. Covers menus, waitstaff, and paying the bill.",
        items: [
            .init(type: .word, content: "Menu", rationale: "A fundamental noun every diner needs to know."),
            .init(type: .word, content: "Order", rationale: "A core verb used when requesting food or drinks."),
            .init(type: .word, content: "Waiter", rationale: "Knowing the word for staff makes it easy to get attention."),
            .init(type: .word, content: "Bill", rationale: "Essential for wrapping up the dining experience."),
            .init(type: .word, content: "Delicious", rationale: "A practical adjective for expressing enjoyment of food."),
            .init(type: .word, content: "Table", rationale: "Used when making reservations or asking for seating."),
            .init(type: .sentence, content: "Can I see the menu, please?", rationale: "The first thing said at almost every restaurant visit."),
            .init(type: .sentence, content: "I would like to order the pasta.", rationale: "Demonstrates using 'order' in a natural dining context."),
            .init(type: .sentence, content: "Excuse me, waiter — could we have the bill?", rationale: "Combines 'waiter' and 'bill' in a complete, polite request."),
        ],
        rationale: "This plan covers the full arc of a restaurant visit using words that appear naturally in the closing sentences."
    )
}
