//
//  File.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-25.
//

import Foundation
import FoundationModels

@Generable
struct Plan {
    @Guide(description: "A single emoji that best describes and visually captures the plan")
    let emoji: String
    @Guide(description: "A short, engaging title describing the plan's theme")
    let title: String
    @Guide(description: "A 1-2 sentence summary of what the plan covers")
    let description: String

    @Guide(description: "A list of things to learn matching user's request", .minimumCount(5), .maximumCount(10))
    let items: [LearningItem]

    @Guide(description: "One sentence in English explaining how the plan meets the user's request; talk as if you're talking directly to the user. Start with 'this plan' as the subject of the sentence.")
    let rationale: String
}

@Generable
struct LearningItem: Equatable, Hashable {
    let type: LearningItemType
    @Guide(description: "The English word or sentence to learn. MUST be in English only.")
    let content: String
    @Guide(description: "One sentence explaining why this item was chosen.")
    let rationale: String
    
    @Generable
    enum LearningItemType: String {
        case word = "Word"
        case sentence = "Sentence"
    }
}
