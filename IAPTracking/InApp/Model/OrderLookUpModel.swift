//
//  OrderLookUpModel.swift
//  IAPurchase
//
//  Created by ejsong on 9/3/24.
//

import Foundation

enum RevocationReason: Int {
    case Accidental = 0
    case AppIssue   = 1
    
    var reason: String {
        switch self {
        case .Accidental: return "단순 변심"
        case .AppIssue: return "앱 동작 이슈"
        }
    }
}

public struct OrderLookUpModel: Equatable, Codable, Identifiable {
    public let id = UUID()
    
    //Data 타입 수정필요
    var originalTransactionId: String = "" //ID
    var transactionReason: String     = ""
    var environment: String           = ""
    var signedDate: TimeInterval     = 0
    var currency: String              = ""
    var originalPurchaseDate: TimeInterval    = 0
    var revocationDate: TimeInterval = 0
    var quantity: Int                 = 0
    var transactionId: String         = ""
    var bundleId: String              = ""
    var price : Int                   = 0           //금액
    var inAppOwnershipType: String    = ""
    var storefront: String            = ""
    var storefrontId: String          = ""
    var purchaseDate: TimeInterval    = 0  //구매 날짜
    var type: String                  = ""
    var productId: String             = ""  //상품 ID
    var revocationReason: Int        = 0   //환불 사유
    
    var revokeReason: RevocationReason? {
        return RevocationReason(rawValue: revocationReason)
    }
    
    var dateFormat: String {
        let date = Date(timeIntervalSince1970: purchaseDate / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date as Date)
    }
    
    var revokeDate: String {
        let date = Date(timeIntervalSince1970: revocationDate / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date as Date)
    }
    
    var originalPrice: Int {
        return price / 1000
    }
    
    enum CodingKeys : String, CodingKey {
        case originalTransactionId
        case transactionReason
        case environment
        case signedDate
        case currency
        case originalPurchaseDate
        case revocationDate
        case quantity
        case transactionId
        case bundleId
        case price
        case inAppOwnershipType
        case storefront
        case storefrontId
        case purchaseDate
        case type
        case productId
    }
    
    public init(from decoder: Decoder) throws {
        let container         = try decoder.container(keyedBy: CodingKeys.self)
        originalTransactionId = (try? container.decode(String.self, forKey: .originalTransactionId)) ?? ""
        transactionReason     = (try? container.decode(String.self, forKey: .transactionReason)) ?? ""
        environment           = (try? container.decode(String.self, forKey: .environment)) ?? ""
        signedDate            = (try? container.decode(TimeInterval.self, forKey: .signedDate)) ?? 0
        currency              = (try? container.decode(String.self, forKey: .currency)) ?? ""
        originalPurchaseDate  = (try? container.decode(TimeInterval.self, forKey: .originalPurchaseDate)) ?? 0
        revocationDate        = (try? container.decode(TimeInterval.self, forKey: .revocationDate)) ?? 0
        quantity              = (try? container.decode(Int.self, forKey: .quantity)) ?? 0
        transactionId         = (try? container.decode(String.self, forKey: .transactionId)) ?? ""
        bundleId              = (try? container.decode(String.self, forKey: .bundleId)) ?? ""
        price                 = (try? container.decode(Int.self, forKey: .price)) ?? 0
        inAppOwnershipType    = (try? container.decode(String.self, forKey: .inAppOwnershipType)) ?? ""
        storefront            = (try? container.decode(String.self, forKey: .storefront)) ?? ""
        storefrontId          = (try? container.decode(String.self, forKey: .storefrontId)) ?? ""
        purchaseDate          = (try? container.decode(TimeInterval.self, forKey: .purchaseDate)) ?? 0
        type                  = (try? container.decode(String.self, forKey: .type)) ?? ""
        productId             = (try? container.decode(String.self, forKey: .productId)) ?? ""

        
    }
}
