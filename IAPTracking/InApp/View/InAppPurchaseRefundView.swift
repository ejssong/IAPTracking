//
//  InAppPurchaseRefundView.swift
//
//  Created by ejsong on 9/4/24.
//

import SwiftUI
import ComposableArchitecture

struct InAppPurchaseRefundView: View {
    @EnvironmentObject private var viewStore: ViewStoreOf<IAPFeature>
    
    var body: some View {
        VStack {
            HStack {
                Text("환불 내역")
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
                
                TableColumn("환불 날짜") { model in
                    Text(String(model.revokeDate))
                }
                
                TableColumn("금액") { model in
                    Text("\(model.originalPrice)")
                }
                
                TableColumn("환불 사유") { model in
                    Text(String(model.revokeReason?.reason ?? ""))
                }
                
            } rows: {
                ForEach(viewStore.refundList) {
                    TableRow($0)
                }
            }

        }
    }
}

#Preview {
    InAppPurchaseRefundView()
}
