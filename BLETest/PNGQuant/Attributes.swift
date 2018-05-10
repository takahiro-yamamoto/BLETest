//
//  Attributes.swift
//  PNGQuant
//
//  Created by Antwan van Houdt on 06/07/2017.
//  Copyright © 2017 Antwan van Houdt. All rights reserved.
//

import Foundation

public enum ImageQuality: Int32 {
    case worst = 0
    case aggressiveOptimisation = 40
    case good  = 80
    case best  = 1
}

class Attributes {
    internal let liqAttr: OpaquePointer
    
    public var maxColors: Int32 {
        get {
            return liq_get_max_colors(liqAttr)
        }
        set {
            liq_set_max_colors(liqAttr, newValue)
        }
    }
    
    init() {
        liqAttr = liq_attr_create()
    }
    
    deinit {
        liq_attr_destroy(liqAttr)
    }
    
    func setQuality(_ imageQuality: ImageQuality) {
        liq_set_quality(liqAttr, 0, imageQuality.rawValue)
    }
    
    func setQualityCustom(minimum: Int32, maximum: Int32) {
        liq_set_quality(liqAttr, minimum, maximum)
    }
}
