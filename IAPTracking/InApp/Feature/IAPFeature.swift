//
//  IAPFeature.swift
//
//  Created by ejsong on 9/4/24.
//

import Foundation
import ComposableArchitecture

public struct IAPFeature: Reducer {

    public init() { }
    
    public struct State: Equatable {
        public var historyList : [OrderLookUpModel] = [] //주문 내역
        public var refundList : [OrderLookUpModel] = [] //환불 내역
        public var type: TabCase = .inAppProduction
    }
    
    public enum Action: Equatable {
        case reqSearch(String)
        case reqChangeType(TabCase)
        case getHistoryList([OrderLookUpModel])
        case getRefundList([OrderLookUpModel])
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .reqSearch(let id):
                
                return .run { send in
                    switch IAPurchaseManager.shared.environment {
                    case .production:
                        let order = try await IAPurchaseManager.shared.getLookUpOrderID(of: id)
                        let history = try await IAPurchaseManager.shared.getRefundHistory(of: id)
                        print("order : \(order)")
                        print("history :: \(history)")
                        await send(.getHistoryList(order))
                        await send(.getRefundList(history))
                    case .sandbox:
                        let receipt = try await IAPurchaseManager.shared.reqReceipt(of: id)
                        
                        await send(.getHistoryList(receipt))
                    default:
                        return
                    }
                }
                
            case .getHistoryList(let historyList):
                state.historyList = historyList
                return .none
                
            case .getRefundList(let refundList):
                state.refundList = refundList
                return .none
            case .reqChangeType(let type):
                IAPurchaseManager.shared.reqChangeClient(of: type.enviornment)
                state.type = type
                return .none
            }
        }
    }

}
