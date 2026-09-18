//
//  ChatBubbleListView.swift
//  Duet
//

import SwiftUI

/// An animated chat bubble list that reveals lines sequentially as `currentStep` advances.
///
/// Lines are keyed by the step number at which they appear. A sliding window of `windowSize`
/// keeps recent lines visible; older lines fade out as the animation progresses.
/// Lines whose key follows a gap in the sequence automatically receive extra top padding,
/// visually separating them into groups.
struct ChatBubbleListView: View {
    let chatLines: [Int: String]
    let currentStep: Int
    var windowSize: Int = 4

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if currentStep >= 0 {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.accentColor)
                    .transition(.blurReplace)
            }

            VStack(alignment: .leading, spacing: 3) {
                ForEach(chatLines.keys.sorted(), id: \.self) { key in
                    if currentStep >= key && currentStep - key <= windowSize {
                        Text(chatLines[key]!)
                            .customFont(.body, weight: .medium)
                            .contentTransition(.opacity)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, isGroupStart(key: key) ? 7 : 0)
                            .transition(.offset(x: -12).combined(with: .blurReplace))
                    }
                }
            }
        }
    }
    
    private func isGroupStart(key: Int) -> Bool {
        let keys = chatLines.keys.sorted()
        guard let index = keys.firstIndex(of: key), index > 0 else { return false }
        return key - keys[index - 1] > 1
    }
}

extension ChatBubbleListView {
    @ViewBuilder
    func applyDefaultStyle(maxWidth: CGFloat = 400) -> some View {
        self
            .alignView(to: .leading)
            .frame(maxWidth: maxWidth)
            .padding()
    }
}
