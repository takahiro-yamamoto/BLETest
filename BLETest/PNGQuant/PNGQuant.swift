//
//  PNGQuant.swift
//  PNGQuant
//
//  Created by Antwan van Houdt on 06/07/2017.
//  Copyright © 2017 Antwan van Houdt. All rights reserved.
//

import Foundation

typealias PNGQuantAttributes = OpaquePointer
typealias PNGQuantImage      = OpaquePointer

struct PNGQuant {
    init() {
        let attributes: PNGQuantAttributes = liq_attr_create()
        
    }
}
