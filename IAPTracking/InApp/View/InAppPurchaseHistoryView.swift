//
//  InAppPurchaseHistoryView.swift
//
//  Created by ejsong on 9/4/24.
//

import SwiftUI
import ComposableArchitecture

struct InAppPurchaseHistoryView: View {
    @EnvironmentObject private var viewStore: ViewStoreOf<IAPFeature>
    
    var body: some View {
        VStack {
            HStack {
                Text("구매 내역")
                    .foregroundStyle(Color.warmGray5)
                    .font(FontManager.shared.font(.semiBold, 14))
                
                Spacer()
            }
            
            Table(of: OrderLookUpModel.self) {
                TableColumn("거래 ID") { model in
                    Text(model.originalTransactionId)
                }
                
                TableColumn("상품") { model in
                    Text(model.productId)
                }
                
                TableColumn("구매 날짜") { model in
                    Text(String(model.dateFormat))
                }
                
                TableColumn("금액") { model in
                    Text("\(model.originalPrice)")
                }
                
            } rows: {
                ForEach(viewStore.historyList) {
                    TableRow($0)
                }
            }
        }
    }
    
}

#Preview {
    InAppPurchaseHistoryView()
}
