//
//  FontManagers.swift
//
//  Created by ejsong on 9/4/24.
//

import Foundation
import SwiftUI

enum FontType: String {
    case light      = "Light"
    case medium     = "Medium"
    case regular    = "Regular"
    case semiBold   = "SemiBold"
    case bold       = "Bold"
    
    func setFontName() -> String {
        return "Pretendard-" + self.rawValue
    }
}

struct FontManager {
    static let shared = FontManager()
    
    func font(_ type: FontType, _ size: CGFloat) -> Font {
        return Font.custom(type.setFontName(), size: size)
    }
    
    func tossFont(_ size: CGFloat) -> Font {
        return Font.custom("TossFaceFontMac", size: size)
    }
}
