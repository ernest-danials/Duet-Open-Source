//
//  File.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-26.
//

import SwiftUI
import Observation
import FoundationModels

@Observable
@MainActor
final class UserInputManager {
    var player1Name: String = ""
    var player2Name: String = ""
    
    var player1Language: Language? = nil
    var player2Language: Language? = nil
    
    var planDescription: String = ""
    var acceptedPlan: Plan.PartiallyGenerated? = nil
    
    var userTranslationsByPlayer1: [GenerationID:String] = [:]
    var userTranslationsByPlayer2: [GenerationID:String] = [:]

    var userPronunciationsByPlayer1: [GenerationID:String] = [:]
    var userPronunciationsByPlayer2: [GenerationID:String] = [:]

    func translationBinding(for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) -> Binding<String> {
        Binding(get: { [self] in
            if forPlayer1 {
                userTranslationsByPlayer1[item.id] ?? ""
            } else {
                userTranslationsByPlayer2[item.id] ?? ""
            }
        }, set: { [self] in
            if forPlayer1 {
                userTranslationsByPlayer1[item.id] = $0
            } else {
                userTranslationsByPlayer2[item.id] = $0
            }
        })
    }
    
    func resetUserTranslation(for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) {
        withAnimation {
            if forPlayer1 {
                userTranslationsByPlayer1[item.id]?.removeAll()
            } else {
                userTranslationsByPlayer2[item.id]?.removeAll()
            }
        }
    }
    
    func isUserTranslationEmpty(for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) -> Bool {
        if forPlayer1 {
            guard let translation = userTranslationsByPlayer1[item.id] else { return true }
            return translation.isEmpty
        } else {
            guard let translation = userTranslationsByPlayer2[item.id] else { return true }
            return translation.isEmpty
        }
    }
    
    func isUserTranslationsIncomplete(for items: [LearningItem.PartiallyGenerated], forPlayer1: Bool) -> Bool {
        items.contains { isUserTranslationEmpty(for: $0, forPlayer1: forPlayer1) }
    }

    func isUserPronunciationsIncomplete(for items: [LearningItem.PartiallyGenerated], forPlayer1: Bool) -> Bool {
        items.contains { isUserPronunciationEmpty(for: $0, forPlayer1: forPlayer1) }
    }
    
    func updateUserTranslation(to newValue: String, for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) {
        withAnimation {
            if forPlayer1 {
                userTranslationsByPlayer1[item.id] = newValue
            } else {
                userTranslationsByPlayer2[item.id] = newValue
            }
        }
    }

    func pronunciationBinding(for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) -> Binding<String> {
        Binding(get: { [self] in
            if forPlayer1 {
                userPronunciationsByPlayer1[item.id] ?? ""
            } else {
                userPronunciationsByPlayer2[item.id] ?? ""
            }
        }, set: { [self] in
            if forPlayer1 {
                userPronunciationsByPlayer1[item.id] = $0
            } else {
                userPronunciationsByPlayer2[item.id] = $0
            }
        })
    }

    func resetUserPronunciation(for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) {
        withAnimation {
            if forPlayer1 {
                userPronunciationsByPlayer1[item.id]?.removeAll()
            } else {
                userPronunciationsByPlayer2[item.id]?.removeAll()
            }
        }
    }

    func isUserPronunciationEmpty(for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) -> Bool {
        if forPlayer1 {
            guard let pronunciation = userPronunciationsByPlayer1[item.id] else { return true }
            return pronunciation.isEmpty
        } else {
            guard let pronunciation = userPronunciationsByPlayer2[item.id] else { return true }
            return pronunciation.isEmpty
        }
    }

    func updateUserPronunciation(to newValue: String, for item: LearningItem.PartiallyGenerated, forPlayer1: Bool) {
        withAnimation {
            if forPlayer1 {
                userPronunciationsByPlayer1[item.id] = newValue
            } else {
                userPronunciationsByPlayer2[item.id] = newValue
            }
        }
    }
}

extension UserInputManager {
    static let preview: UserInputManager = MainActor.assumeIsolated {
        let manager = UserInputManager()
        manager.player1Name = "Alice"
        manager.player2Name = "Bob"

        guard let plan = try? Plan.PartiallyGenerated(Plan.example.generatedContent) else { return manager }
        manager.acceptedPlan = plan

        let player1Translations: [String: String] = [
            "Menu": "메뉴", "Order": "주문", "Waiter": "웨이터", "Bill": "계산서",
            "Delicious": "맛있는", "Table": "테이블",
            "Can I see the menu, please?": "메뉴 좀 볼 수 있을까요?",
            "I would like to order the pasta.": "파스타를 주문하고 싶어요.",
            "Excuse me, waiter — could we have the bill?": "저기요, 계산서 주시겠어요?"
        ]
        let player1Pronunciations: [String: String] = [
            "Menu": "me-nyu", "Order": "ju-mun", "Waiter": "we-i-teo",
            "Bill": "gye-san-seo", "Delicious": "mas-in-neun", "Table": "te-i-beul",
            "Can I see the menu, please?": "me-nyu jom bol su i-sseul-kka-yo?",
            "I would like to order the pasta.": "pa-seu-ta-reul ju-mun-ha-go si-peo-yo.",
            "Excuse me, waiter — could we have the bill?": "jeo-gi-yo, gye-san-seo ju-si-ge-sseo-yo?"
        ]
        let player2Translations: [String: String] = [
            "Menu": "菜单", "Order": "点餐", "Waiter": "服务员", "Bill": "账单",
            "Delicious": "美味", "Table": "桌子",
            "Can I see the menu, please?": "请给我看一下菜单。",
            "I would like to order the pasta.": "我想点意面。",
            "Excuse me, waiter — could we have the bill?": "不好意思，服务员，请买单。"
        ]
        let player2Pronunciations: [String: String] = [
            "Menu": "cài-dān", "Order": "diǎn-cān", "Waiter": "fú-wù-yuán",
            "Bill": "zhàng-dān", "Delicious": "měi-wèi", "Table": "zhuō-zi",
            "Can I see the menu, please?": "qǐng gěi wǒ kàn yī xià cài-dān.",
            "I would like to order the pasta.": "wǒ xiǎng diǎn yì-miàn.",
            "Excuse me, waiter — could we have the bill?": "bù-hǎo-yì-si, fú-wù-yuán, qǐng mǎi-dān."
        ]

        for item in plan.items ?? [] {
            guard let content = item.content else { continue }
            manager.userTranslationsByPlayer1[item.id] = player1Translations[content] ?? content
            manager.userPronunciationsByPlayer1[item.id] = player1Pronunciations[content] ?? ""
            manager.userTranslationsByPlayer2[item.id] = player2Translations[content] ?? content
            manager.userPronunciationsByPlayer2[item.id] = player2Pronunciations[content] ?? ""
        }
        return manager
    }
}

private struct UserInputManagerKey: EnvironmentKey {
    static let defaultValue: UserInputManager = MainActor.assumeIsolated { UserInputManager() }
}

extension EnvironmentValues {
    var userInputManager: UserInputManager {
        get { self[UserInputManagerKey.self] }
        set { self[UserInputManagerKey.self] = newValue }
    }
}
