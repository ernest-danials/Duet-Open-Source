//
//  File.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-26.
//

import Foundation

enum GenerationError {
    case refusal
    case assetsUnavailable
    case decodingFailure
    case exceededContextWindowSize
    case guardrailViolation
    case rateLimited
    case concurrentRequests
    case unsupportedLanguageOrLocale
    case unsupportedGuide
    case unknown

    var message: String {
        switch self {
        case .refusal:
            return "The request was refused. Please try a different description."
        case .assetsUnavailable:
            return "Apple Intelligence is unavailable. Please check your device settings and try again."
        case .decodingFailure:
            return "The plan could not be read. Please try again."
        case .exceededContextWindowSize:
            return "The session has reached its context window size limit."
        case .guardrailViolation:
            return "The request contained content that does not meet our safety guidelines. Please try a different description."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .concurrentRequests:
            return "A plan is already being generated. Please wait for it to finish."
        case .unsupportedLanguageOrLocale:
            return "The selected language is not supported by Apple Intelligence."
        case .unsupportedGuide:
            return "The plan format is not supported. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
