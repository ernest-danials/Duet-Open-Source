//
//  AboutView.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-12-02.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let versionString: String = "Version " + "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"))"

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    Image(.appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)

                    Text("Duet")
                        .customFont(.title3, weight: .bold)

                    Text(versionString)
                        .customFont(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding()

                    Link(destination: URL(string: "https://myungjoon.com/duet")!) {
                        buttonLabel(title: "Duet Website", imageName: "globe", color: .accent, showArrow: true)
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)

                    Link(destination: URL(string: "https://myungjoon.com/hello")!) {
                        buttonLabel(title: "Developer Website", imageName: "person.crop.circle", color: .accent, showArrow: true)
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                    
                    Link(destination: URL(string: "https://myungjoon.com/duet/privacy")!) {
                        buttonLabel(title: "Privacy Policy", imageName: "hand.raised.fill", color: .blue, showArrow: true)
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                    
                    NavigationLink {
                        creditsView()
                    } label: {
                        buttonLabel(title: "Credits", imageName: "star.fill", color: .yellow)
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                    
                    Divider()
                        .padding([.horizontal, .top])
                        .padding(.bottom, 2)

                    Text("Copyright © 2026 Myung Joon Kang. All rights reserved.")
                        .customFont(.caption)
                        .foregroundColor(.secondary)
                        .alignView(to: .leading)
                        .padding(.horizontal)
                }
            }
            .background(colorScheme == .light ? Color("Cream") : Color("CharcoalMist"))
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "xmark", role: .close) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func creditsView() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                creditSection(title: "Special Thanks") {
                    creditRow(name: "Sayan Lakhoua", role: "Beta Tester", socialURL: URL(string: "https://x.com/sayan_lakhoua"))
                }
            }
            .padding()
        }
        .background(colorScheme == .light ? Color("Cream") : Color("CharcoalMist"))
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func creditSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .customFont(.caption, weight: .semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.leading, 8)

            VStack(spacing: 0) {
                content()
            }
            .applyGlassEffect()
        }
    }

    @ViewBuilder
    private func creditRow(name: String, role: String, imageName: String? = nil, socialURL: URL? = nil) -> some View {
        let rowContent = HStack(spacing: 12) {
            profileAvatar(name: name, imageName: imageName)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .customFont(.body, weight: .medium)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Text(role)
                    .customFont(.footnote)
                    .foregroundStyle(.gray)
            }

            Spacer()

            if socialURL != nil {
                Image(systemName: "arrow.up.right")
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 8)

        if let url = socialURL {
            Link(destination: url) { rowContent }
        } else {
            rowContent
        }
    }

    @ViewBuilder
    private func profileAvatar(name: String, imageName: String?) -> some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        } else {
            let initials = name.split(separator: " ").compactMap(\.first).map(String.init).joined()
            let colors: [Color] = [.accentColor, Color("SoftBlush"), Color("RoseQuartz"), Color("SageGreen")]
            let colorIndex = abs(name.hashValue) % colors.count
            Text(initials)
                .customFont(.caption, weight: .bold)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(colors[colorIndex])
                .clipShape(Circle())
        }
    }

    private func buttonLabel(title: String, imageName: String, color: Color, showArrow: Bool = false, tintText: Bool = false) -> some View {
        HStack {
            Image(systemName: imageName)
                .foregroundStyle(color)

            if tintText {
                Text(title)
                    .customFont(.body, weight: .medium)
                    .foregroundStyle(color)
            } else {
                Text(title)
                    .customFont(.body, weight: .medium)
            }

            Spacer()

            if showArrow {
                Image(systemName: "arrow.up.right")
                    .fontWeight(.medium)
                    .foregroundStyle(color.secondary)
            }
        }
        .padding(7)
        .padding(.vertical, 3)
    }
}

#Preview {
    AboutView()
}
