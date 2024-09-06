//
//  TabCase.swift
//
//  Created by ejsong on 9/4/24.
//

import Foundation
import AppStoreServerLibrary

public enum TabCase {
    case inAppProduction
    case inAppSandBox
    
    var value: String {
        switch self {
        case .inAppProduction: return "PRODUCTION (실서버)"
        case .inAppSandBox: return "SANDBOX (개발)"
        }
    }
    
    var emoji: String {
        switch self {
        case .inAppProduction: return "👑"
        case .inAppSandBox: return "🛟"
        }
    }
    
    var enviornment: Environment {
        switch self {
        case .inAppProduction: return .production
        case .inAppSandBox: return .sandbox
        }
    }
}

