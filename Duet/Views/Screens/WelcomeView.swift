//
//  WelcomeView.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-12-02.
//

import SwiftUI

private struct LanguagePhrase {
    let prefix: String
    let exchangeWord: String
    let part1: String
    let teacherWord: String
    let part2: String
    let studentWord: String
    let suffix: String
}

struct WelcomeView: View {
    @Environment(\.stepManager) private var stepManager: StepManager

    @State private var animationStep: Int = 0
    @State private var languageIndex: Int = 0
    @State private var isShowingAboutView: Bool = false

    private static let phrases: [LanguagePhrase] = [
        LanguagePhrase(prefix: "", exchangeWord: "Exchange", part1: " languages, \nAs a ", teacherWord: "teacher", part2: " and a ", studentWord: "student", suffix: "."),
        LanguagePhrase(prefix: "언어를 ", exchangeWord: "교환해요", part1: ", \n", teacherWord: "선생님", part2: "과 ", studentWord: "학생", suffix: "으로서."),
        LanguagePhrase(prefix: "", exchangeWord: "交换", part1: "语言，\n作为", teacherWord: "老师", part2: "和", studentWord: "学生", suffix: "。"),
        LanguagePhrase(prefix: "", exchangeWord: "Intercambia", part1: " idiomas, \ncomo ", teacherWord: "maestro", part2: " y ", studentWord: "estudiante", suffix: "."),
        LanguagePhrase(prefix: "", exchangeWord: "Échangez", part1: " les langues, \nEn tant qu'", teacherWord: "enseignant", part2: " et qu'", studentWord: "étudiant", suffix: "."),
    ]
    
    private var currentPhrase: LanguagePhrase { Self.phrases[languageIndex] }
    
    private func phraseText(_ phrase: LanguagePhrase) -> Text {
        Text("\(phrase.prefix)\(Text(phrase.exchangeWord).foregroundColor(.accentColor))\(phrase.part1)\(Text(phrase.teacherWord).foregroundColor(Color("SoftBlush")))\(phrase.part2)\(Text(phrase.studentWord).foregroundColor(Color("RoseQuartz")))\(phrase.suffix)")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if animationStep >= 1 {
                phraseText(currentPhrase)
                    .customFont(.largeTitle, weight: .black)
                    .transition(.blurReplace)
                    .id(languageIndex)
            }
            
            if animationStep >= 2 {
                Text("Sit together. Teach your native language, and learn theirs. \nPowered by Apple Intelligence. Driven by human connection.")
                    .customFont(.body, weight: .medium)
                    .foregroundStyle(.secondary)
                    .transition(.blurReplace)
            }
            
            if animationStep >= 3 {
                HStack {
                    Button {
                        stepManager.changeStep(.pickOrientation)
                    } label: {
                        Text("Begin")
                            .customFont(.title2, weight: .semibold)
                            .padding(7)
                            .padding(.horizontal, 7)
                    }
                    .buttonStyle(.glassProminent)
                    .transition(.blurReplace)
                    .padding(.top)
                    
                    Button {
                        isShowingAboutView = true
                    } label: {
                        Text("About")
                            .customFont(.title2, weight: .semibold)
                            .foregroundStyle(.accent)
                            .padding(7)
                            .padding(.horizontal, 7)
                    }
                    .buttonStyle(.glass)
                    .transition(.blurReplace)
                    .padding(.top)
                }
            }
        }
        .frame(width: 700, alignment: .leading)
        .alignView(to: .center)
        .alignViewVertically(to: .center)
        .sheet(isPresented: $isShowingAboutView) {
            AboutView()
        }
        .task {
            await startAnimation()
        }
    }
    
    private func startAnimation() async {
        for step in 1...3 {
            try? await Task.sleep(nanoseconds: 800_000_000)
            withAnimation(.spring(duration: 0.4)) {
                animationStep = step
            }
        }
        
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            withAnimation(.spring(duration: 0.4)) {
                languageIndex = (languageIndex + 1) % Self.phrases.count
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
}

#Preview(traits: .portrait) {
    ContentView()
        .environment(StepManager())
        .preferredColorScheme(.dark)
}
