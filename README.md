# Duet

**Making collaborative language learning tangible.**

Duet is a collaborative language learning app that bridges two people with
different native languages, with AI as a quiet assistant. Two people sit at a
single iPad and take turns teaching each other their target languages, guided by
a learning plan that Apple Intelligence generates on-device from a short
description of what the pair wants to learn.

Rather than drilling a learner against an app, Duet makes each player the other's
teacher — the person who already speaks the language supplies the translation, and
the app handles the scaffolding around it.

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ernest-danials/Duet-Open-Source)

## A concept, honestly

Duet was always a concept more than a product. I built it for the Swift Student
Challenge 2026 to demonstrate an idea: that language learning should be social,
and that an app could act as a bridge between two people rather than standing
between them as a teacher. It wasn't selected, but the idea holds up — and it was
the first project I built around
[Communication](https://myungjoon.com/values/communication), one of my three
values.

The distance between a concept and an app people can rely on every day is much
longer than a single submission, and I didn't want to ship something that isn't
really a product. The alternative — letting it sit in a private repository and
exist only through screenshots — felt like the wrong ending for something I
believe in. So Duet isn't coming to the App Store; the full Xcode project I
submitted is here instead, under the MIT licence.

If the idea speaks to you, clone it, run it locally and try it. If any of the code
is useful, fork it and take the part you want — or build the version of Duet that
I didn't.

- [Introducing Duet](https://myungjoon.com/blog/introducing-duet) — the original
  write-up
- [Duet is not coming to the App Store. It's going to GitHub](https://myungjoon.com/blog/duet-is-not-coming-to-the-app-store.-it-s-going-to-github)
  — the open-source announcement
- [Project page](https://myungjoon.com/duet) · [Privacy policy](https://myungjoon.com/duet/privacy)

## How a session works

1. **Set up** — choose a seating arrangement (side-by-side or face-to-face), then
   each player picks a name and the language they want to learn.
2. **Create a plan** — describe the lesson in a sentence or two. The model streams
   back a plan of vocabulary and phrases, which both players accept before starting.
3. **Translate** — each player privately translates the plan's items into their own
   language, with AI-suggested translations and romanised pronunciations to lean on.
4. **Learn together** — the pair works through a card-reveal phase, teaching each
   other what they wrote.
5. **Play** — a memory-style matching game pairs English words with both players'
   translations to close out the session.

Most transitions require *both* players to tap confirm before the session moves on,
so neither can race ahead. The translation step is the one exception: it belongs to
a single player at a time, and ends with an explicit hand-over of the iPad.

## Requirements

- **iPad** running **iPadOS 26.0 or later** — the layout is built for a shared
  landscape or face-to-face split screen and is not designed for iPhone
- A device with **Apple Intelligence** available and enabled
- A keyboard installed in Settings for each language being learned — the app checks
  for one before letting a player continue past language selection
- **Xcode 26** or later to build

Duet uses Apple's on-device foundation models through the `FoundationModels`
framework, so plan generation, translation and pronunciation all run locally —
no network requests and no accounts.

## Supported learning languages

🇰🇷 Korean · 🇨🇳 Chinese · 🇪🇸 Spanish · 🇫🇷 French

## Building

Duet isn't distributed through the App Store, so the only way to run it is to
build it yourself:

```bash
git clone https://github.com/ernest-danials/Duet-Open-Source.git
cd Duet-Open-Source
open Duet.xcodeproj
```

Select an iPad destination and run (⌘R). On first launch the app checks whether
Apple Intelligence is available and shows an explanatory fallback screen if it
is not, so a simulator or unsupported device will build and launch but will not
reach the main flow.

## Project structure

```
Duet/
├── Enums/                          Language and error types
├── Managers/                       Step navigation and session state (@Observable)
├── Foundation Models Framework/    @Generable models and the three generators
├── Views/
│   ├── Screens/                    One view per step in the flow
│   └── Components/                 Split-screen container, dual-confirm button, …
├── Extensions/
└── Assets.xcassets/
```

Navigation is a single `StepManager` that walks through the session's steps, with
`ContentView` switching on the current step. Shared session state — names,
languages, the accepted plan, and each player's translations — lives in a
`UserInputManager` injected through the environment.

## Design notes

- **Typing only where it's unavoidable.** Nicknames, languages and seating are all
  picked by tapping, since two people cannot comfortably share one software
  keyboard. Text entry is limited to two places: the lesson description (a single
  centred overlay, with a rotated "ask your partner to type" hint when face-to-face)
  and each player's own translation and pronunciation fields, which only that player
  is holding the iPad for.
- **Orientation-aware layout.** In landscape the screen splits side-by-side; in
  portrait it splits vertically and rotates the second player's half 180° so the
  players can sit facing each other.
- **Streaming generation.** Plans render incrementally as the model produces them,
  animated in rather than appearing after a blocking wait.

## Status

This repository is the project as it was submitted — a working concept, not a
maintained product, and I'm not planning to develop it into one. Forks are very
much encouraged and need no permission. If you do want to extend it in place,
adding a language is the easiest first change: each `Language` case needs an
emoji, a display name and a BCP-47 prefix used to check whether a matching
keyboard is installed.

## Licence

Released under the [MIT Licence](LICENSE). © 2025–2026 Myung Joon Kang
