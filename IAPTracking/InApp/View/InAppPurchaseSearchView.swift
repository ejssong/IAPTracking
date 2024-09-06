//
//  InAppPurchaseSearchView.swift
//
//  Created by ejsong on 9/4/24.
//

import SwiftUI
import ComposableArchitecture

struct InAppPurchaseSearchView: View {
  
    @EnvironmentObject private var viewStore: ViewStoreOf<IAPFeature>
    @State var text: String = ""
    
    var body: some View {
        HStack {

            TextField("주문번호 / Transaction ID 를 입력해주세요", text: $text)
                .foregroundStyle(Color.warmGray5)
                .font(FontManager.shared.font(.regular, 14))
                .textFieldStyle(.roundedBorder)
                .frame(width: 300, height: 30)
            
            Spacer()
            
            Button {
                viewStore.send(.reqSearch(text))
            } label: {
                Text("조회")
                    .foregroundStyle(Color.warmGray5)
                    .font(FontManager.shared.font(.bold, 14))
                    .frame(width: 80, height: 30)
                    
            }
            .tint(Color.grayScale2)
            .buttonBorderShape(.capsule)
        }
        .frame(height: 50)

    }
}



#Preview {
    InAppPurchaseSearchView()
}
