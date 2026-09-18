# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Duet is a two-player collaborative language learning iOS app built with SwiftUI and Apple Intelligence (FoundationModels). Two players share one iPad and take turns learning each other's target languages through AI-generated plans, translation exercises, and a matching game.

**Target:** iPad only. Keyboard input is confined to two places — the plan description (`TextInputOverlay` in `CreatePlanView`) and each player's translation/pronunciation fields (`TranslationView`). Everything else in the two-player UI is tap-based selection (lists, buttons).

## Building and Running

This is a standard Xcode project (`.xcodeproj`):

- **Open in Xcode**: Open `Duet.xcodeproj`
- **Build**: Cmd+B in Xcode
- **Run**: Cmd+R in Xcode (select target device/simulator)
- **Swift Version**: Swift 6.0
- **iOS Target**: iOS 26.0+ (Apple Intelligence required)
- **Bundle ID**: `com.myungjoon.Duet`

## Architecture

### Project Structure

```
Duet/
├── DuetApp.swift
├── Enums/
│   ├── Language.swift                  # Korean, Chinese, Spanish, French
│   └── GenerationError.swift           # 10 AI error types with user messages
├── Managers/
│   ├── StepManager.swift               # @Observable step-based navigation
│   └── UserInputManager.swift          # @Observable @MainActor session state
├── Foundation Models Framework/
│   ├── Models/
│   │   └── Plan.swift                  # @Generable Plan and LearningItem structs
│   ├── Generators/
│   │   ├── PlanGenerator.swift         # Streaming plan generation
│   │   ├── TranslationGenerator.swift  # Word/sentence translation
│   │   └── PronunciationGenerator.swift # Romanized pronunciation
│   └── PromptingTest.swift             # Dev testing file
├── Views/
│   ├── Screens/
│   │   ├── ContentView.swift           # Step router (switch on StepManager.step)
│   │   ├── WelcomeView.swift           # Animated multilingual intro
│   │   ├── PickOrientationView.swift   # Side-by-side vs face-to-face setup
│   │   ├── PickNameAndLanguageView.swift
│   │   ├── CreatePlanView.swift        # Chat UI + streaming plan generation
│   │   ├── LearnTogetherIntroView.swift
│   │   ├── TranslationView.swift       # Per-player AI-assisted translation entry
│   │   ├── CollaborativeLearningIntroView.swift
│   │   ├── CollaborativeLearningView.swift # Card reveal teaching phase
│   │   ├── MatchingGameIntroView.swift
│   │   ├── MatchingGameView.swift      # Memory-style matching game
│   │   └── AboutView.swift             # Version, links, credits (sheet)
│   └── Components/
│       ├── TwoPlayersView.swift        # Split-screen container (landscape/portrait aware)
│       ├── DualConfirmButton.swift     # Both players must confirm to proceed
│       ├── ChatBubbleListView.swift    # Animated sliding chat dialogue
│       ├── TextInputOverlay.swift      # Centered text input with char limit
│       └── GeneratedPlanCardContent.swift
├── Extensions/
│   ├── View+Ext.swift                  # alignView, applyGlassEffect, customFont
│   ├── GeometryProxy+Ext.swift         # isLandscape computed property
│   └── String+Ext.swift               # pluralised(for:)
├── Others/
│   └── RoundedCorner.swift
└── Assets.xcassets/
    └── Colors/                         # SoftBlush, SageGreen, RoseQuartz,
                                        # SoftPearl, Cream, CharcoalMist
```

### Key Architectural Patterns

**Step-Based Navigation (`StepManager`)**
- `@Observable` class injected via environment
- 12 steps: `welcome` → `pickOrientation` → `pickNameAndLanguage` → `createPlan` → `learnTogetherIntro` → `player1Translation` → `player2Translation` → `collaborativeLearningIntro` → `collaborativeLearning` → `matchingGameIntro` → `matchingGame` → back to `welcome`
- `ContentView` switches on the current step to display the correct screen

**Session State (`UserInputManager`)**
- `@Observable @MainActor` class injected via environment
- Stores player names, languages, `planDescription`, `acceptedPlan`
- Tracks `userTranslationsByPlayer1/2[GenerationID: String]` and pronunciations
- Includes validation helpers for incomplete data

**Apple Intelligence Integration**
- `FoundationModels` framework with `@Generable` macro for structured output
- `PlanGenerator`, `TranslationGenerator`, `PronunciationGenerator` — all `@MainActor`
- Streaming responses update UI incrementally via `withAnimation`
- Custom `GenerationError` enum maps framework errors to user-friendly messages
- Session prewarming with `prewarm()` before first use

**Two-Player Layout (`TwoPlayersView`)**
- Landscape: side-by-side horizontal split
- Portrait: vertical split with Player 2 rotated 180° (face-to-face)
- Orientation detected via `GeometryProxy.isLandscape`
- `DualConfirmButton` requires both players to tap before advancing

**Glass Morphism UI**
- iOS 26 native `.glassEffect()` via `applyGlassEffect()` extension on `View`
- `Color("ColorName")` pattern for all custom colors from Assets

### Color System

| Name | Usage |
|------|-------|
| `SoftBlush` | English words in MatchingGameView |
| `SageGreen` | Player 1 translations in MatchingGameView |
| `RoseQuartz` | Player 2 translations in MatchingGameView |
| `Cream` | Light mode background |
| `CharcoalMist` | Dark mode background |
| `SoftPearl` | Accent variant |

### Supported Languages (for learning)

Korean, Chinese, Spanish, French — each has an emoji, display name, and keyboard availability check.

## Development Notes

- `DuetApp.swift` checks content availability and shows a fallback screen if Apple Intelligence is unavailable
- Don't add new keyboard/text field input to the two-player flow beyond the plan description and translation fields — use tap-based selection
- All AI generators must be `@MainActor` for thread safety
- `PromptingTest.swift` in `Foundation Models Framework/` is a dev testing file — not part of the main app flow
