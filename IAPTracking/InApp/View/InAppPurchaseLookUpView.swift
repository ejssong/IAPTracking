//
//  InAppPurchaseLookUpView.swift
//
//  Created by ejsong on 9/4/24.
//

import SwiftUI
import ComposableArchitecture

struct InAppPurchaseLookUpView: View {
    
    @EnvironmentObject var viewStore: ViewStoreOf<IAPFeature>
    
    var type: TabCase = .inAppProduction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            Text(type.value)
                .foregroundStyle(Color.warmGray6)
                .font(FontManager.shared.font(.bold, 20))
            
            switch type {
            case .inAppProduction:
                Text("""
                    실서버 결제 확인용입니다. 주문번호로 검색해 주세요
                    """)
                .foregroundStyle(Color.grayScale3)
                .font(FontManager.shared.font(.bold, 14))
                
            case .inAppSandBox:
                Text("""
                    개발 결제 확인용입니다. Transaction ID로 검색해 주세요
                    """)
                .foregroundStyle(Color.grayScale3)
                .font(FontManager.shared.font(.bold, 14))
            }
            
            InAppPurchaseSearchView()
            
            InAppPurchaseHistoryView()
            
            InAppPurchaseRefundView()
            
        }
        .textSelection(.enabled)
        .padding(.all, 40)
        .onChange(of: type, perform: { value in
            viewStore.send(.reqChangeType(value))
        })
    }
    
}




#Preview {
    InAppPurchaseLookUpView()
}
