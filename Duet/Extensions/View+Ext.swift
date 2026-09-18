//
//  View+Ext.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-10-18.
//

import SwiftUI

extension View {
    @ViewBuilder
    func alignView(to: HorizontalAlignment) -> some View {
        HStack {
            if to != .leading {
                Spacer()
            }
            
            self
            
            if to != .trailing {
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func alignViewVertically(to: VerticalAlignment) -> some View {
        VStack {
            if to != .top {
                Spacer()
            }
            
            self
            
            if to != .bottom {
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func customFont(_ style: Font.TextStyle, weight: Font.Weight = .regular, design: Font.Design = .rounded) -> some View {
        if weight != .regular {
            self.font(.system(style, design: design).weight(weight))
        } else {
            self.font(.system(style, design: design))
        }
    }
    
    @ViewBuilder
    func applyGlassEffect<S: Shape>(in shape: S = RoundedRectangle(cornerRadius: 20), padding paddingAmount: CGFloat? = nil, isInteractive: Bool = false) -> some View {
        self
            .safeAreaPadding(.all, paddingAmount)
            .glassEffect(.regular.interactive(isInteractive), in: shape)
    }

    @ViewBuilder
    func applyGlassEffect<S: Shape>(in shape: S = RoundedRectangle(cornerRadius: 20), padding paddingInsets: EdgeInsets, isInteractive: Bool = false) -> some View {
        self
            .safeAreaPadding(paddingInsets)
            .glassEffect(.regular.interactive(isInteractive), in: shape)
    }
}

extension Binding where Value == Int {
    func animate(from start: Int, to end: Int, delay: UInt64 = 1_000_000_000, skip: [Int] = []) {
        Task {
            for step in start...end {
                guard !skip.contains(step) else { continue }
                withAnimation {
                    wrappedValue = step
                }
                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }
}
