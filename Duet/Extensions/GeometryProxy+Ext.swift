//
//  GeometryProxy+Ext.swift
//  Duet
//
//  Created by Myung Joon Kang on 2026-02-08.
//

import SwiftUI

extension GeometryProxy {
    var isLandscape: Bool {
        return (self.size.width > self.size.height)
    }
}
