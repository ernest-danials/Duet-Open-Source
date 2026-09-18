//
//  GeneratedPlanCard.swift
//  Duet
//

import SwiftUI
import FoundationModels

struct GeneratedPlanCardContent: View {
    let plan: Plan.PartiallyGenerated

    var body: some View {
        LazyVStack(alignment: .leading) {
            if let emoji = plan.emoji {
                Text(emoji)
                    .customFont(.largeTitle, weight: .heavy)
                    .contentTransition(.opacity)
                    .transition(.blurReplace)
            }

            if let title = plan.title {
                Text(title)
                    .customFont(.title, weight: .heavy)
                    .contentTransition(.opacity)
                    .transition(.blurReplace)
            }

            if let description = plan.description {
                Text(description)
                    .customFont(.headline, weight: .medium)
                    .foregroundStyle(.primary.secondary)
                    .contentTransition(.opacity)
                    .transition(.blurReplace)
            }

            if let items = plan.items {
                Divider()
                    .padding(.vertical, 5)
                    .contentTransition(.opacity)
                    .transition(.blurReplace)

                ForEach(items) { item in
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 2) {
                            if let type = item.type {
                                Text(type.rawValue)
                                    .customFont(.caption)
                                    .foregroundStyle(.primary.secondary)
                                    .contentTransition(.opacity)
                                    .transition(.blurReplace)
                            }

                            if let content = item.content {
                                Text(content)
                                    .customFont(.body, weight: .medium)
                                    .contentTransition(.opacity)
                                    .transition(.blurReplace)
                            }
                        }

                        if let rationale = item.rationale {
                            Text(rationale)
                                .customFont(.subheadline)
                                .foregroundStyle(.primary.secondary)
                                .contentTransition(.opacity)
                                .transition(.blurReplace)
                        }

                        Divider()
                            .contentTransition(.opacity)
                            .transition(.blurReplace)
                    }
                    .padding(.bottom, 5)
                    .id(item.id)
                }
            }
        }
        .transition(.blurReplace)
    }
}
