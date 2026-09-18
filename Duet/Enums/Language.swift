//
//  File.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-26.
//

import Foundation
import UIKit

enum Language: String, CaseIterable {
    case korean = "Korean"
    case chinese = "Chinese"
    case spanish = "Spanish"
    case french = "French"

    var emoji: String {
        switch self {
        case .korean:
            return "🇰🇷"
        case .chinese:
            return "🇨🇳"
        case .spanish:
            return "🇪🇸"
        case .french:
            return "🇫🇷"
        }
    }

    var nameWithEmoji: String {
        return "\(self.emoji) \(self.rawValue)"
    }

    /// The BCP-47 language prefix used to identify the corresponding keyboard.
    var keyboardLanguagePrefix: String {
        switch self {
        case .korean:  return "ko"
        case .chinese: return "zh"
        case .spanish: return "es"
        case .french:  return "fr"
        }
    }

    /// Returns `true` if the device has at least one keyboard whose primary
    /// language matches this language.\
    @MainActor
    var isKeyboardAvailable: Bool {
        let installedLanguages = UITextInputMode.activeInputModes.compactMap { $0.primaryLanguage }
        return installedLanguages.contains { $0.hasPrefix(keyboardLanguagePrefix) }
    }
}
