//
//  String+Ext.swift
//  Duet
//
//  Created by Myung Joon Kang on 2025-10-25.
//

import Foundation

extension String {
    func pluralised(for number: Int) -> Self {
        guard number != 1 else { return self }
        
        let lowercased = self.lowercased()
        
        // Words ending with 'y' after a consonant → 'ies'
        if lowercased.hasSuffix("y"), let beforeY = self.dropLast().last, !"aeiou".contains(beforeY.lowercased()) {
            return String(self.dropLast()) + "ies"
        }
        
        // Words ending with 's', 'x', 'z', 'ch', 'sh' → add 'es'
        if lowercased.hasSuffix("s") || lowercased.hasSuffix("x") || lowercased.hasSuffix("z") || lowercased.hasSuffix("ch") || lowercased.hasSuffix("sh") {
            return self + "es"
        }
        
        // Default case → add 's'
        return self + "s"
    }
}
