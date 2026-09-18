//
//  TextInputOverlay.swift
//  Duet
//

import SwiftUI

struct TextInputOverlay: View {
    @Binding var text: String
    var title: String
    var placeholder: String
    var partnerHint: String?
    var characterLimit: Int?
    var onSubmit: () -> Void

    init(text: Binding<String>, title: String, placeholder: String = "Type here", partnerHint: String? = "Ask your partner to type", characterLimit: Int? = nil, onSubmit: @escaping () -> Void) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self.partnerHint = partnerHint
        self.characterLimit = characterLimit
        self.onSubmit = onSubmit
    }

    @FocusState private var isFocused: Bool

    private var characterCount: Int { text.count }
    private var isOverLimit: Bool { characterCount > characterLimit ?? 0 }

    var body: some View {
        GeometryReader { geo in
            VStack {
                if !geo.isLandscape, let partnerHint {
                    Text(partnerHint)
                        .customFont(.title3, weight: .semibold)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(180))
                        .transition(.blurReplace)
                }

                VStack(alignment: .leading) {
                    Text(title)
                        .customFont(.headline, weight: .medium)
                        .padding(.leading)

                    HStack {
                        HStack {
                            TextField(text: $text) {
                                Text(placeholder)
                                    .customFont(.body)
                            }
                            .focused($isFocused)
                            .customFont(.body)
                            .submitLabel(.send)
                            .onSubmit {
                                onSubmit()
                                withAnimation { isFocused = false }
                            }

                            Button {
                                withAnimation { text.removeAll() }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .disabled(text.isEmpty)
                            .opacity(text.isEmpty ? 0.0 : 1.0)
                        }
                        .applyGlassEffect(isInteractive: true)

                        Button {
                            onSubmit()
                            withAnimation { isFocused = false }
                        } label: {
                            Image(systemName: "arrow.up")
                                .customFont(.headline, weight: .semibold)
                                .padding(5)
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(text.isEmpty || isOverLimit)
                    }

                    if let characterLimit {
                        Text("\(characterCount)/\(characterLimit)")
                            .customFont(.caption2)
                            .foregroundStyle(isOverLimit ? .red : .secondary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.default, value: characterCount)
                            .padding(.leading)
                    }
                }
                .alignViewVertically(to: .center)
                .offset(y: isFocused ? (geo.isLandscape ? -(geo.size.height / 4.1) : -(geo.size.height / 8)) : 0)
                .animation(.easeInOut, value: isFocused)
            }
            .frame(maxWidth: 600)
            .alignView(to: .center)
        }
        .transition(.blurReplace)
    }
}
