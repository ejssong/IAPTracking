//
//  ContentView.swift
//  IAPTracking
//
//  Created by ejsong on 9/6/24.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

    @State var type: TabCase = .inAppProduction
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack {
                HeaderView()
                  
                Divider()
                    .foregroundStyle(.gray102)
                    .frame(height: 3)
                    
                HStack(spacing: 0) {
                    TabView(type: $type)
                        .background(Color.grayScale1)
                    
                    Divider()
                        .foregroundStyle(.gray102)
                        .frame(height: 3)
                    
                    InAppPurchaseLookUpView(type: type)
                        .environmentObject(getIAPFeature())
                
                }
                Spacer()
            }
        }
        .preferredColorScheme(.light)
       
    }
    
    func getIAPFeature() -> ViewStoreOf<IAPFeature> {
        
        let store = Store(initialState: IAPFeature.State(), reducer: { IAPFeature() })
        
        let viewStore = ViewStore(store, observe: { $0 })
        
        dump(viewStore)
    
        return viewStore
    }
}

struct HeaderView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Text("IAP TRACKING")
                .font(FontManager.shared.font(.bold, 16))
                .foregroundStyle(Color.warmGray5)
            
            Spacer()
        }
        .padding()
    }
}


struct TabView: View {
    @Binding var type: TabCase
    
    var body: some View {

        VStack(alignment: .leading, spacing: 20) {
            
            Spacer()
                .frame(height: 20)
            
            Text("인 앱 결제 추적")
                .font(FontManager.shared.font(.bold, 13))
                .foregroundStyle(Color.grayScale3)
            
            TabCellView(selectedType: $type, type: .inAppProduction)
                .onTapGesture {
                    type = .inAppProduction
                }
            
            TabCellView(selectedType: $type, type: .inAppSandBox)
                .onTapGesture {
                    type = .inAppSandBox
                }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 80))
        .overlay(
            
            Divider()
                .frame(width: 1, height: nil, alignment: .trailing)
                .foregroundStyle(.gray102), alignment: .trailing
        )
    }
}


struct TabCellView: View {
    @Binding var selectedType: TabCase
    
    var type: TabCase
    
    var body: some View {
        
        HStack {
            Text(type.emoji)
                .font(FontManager.shared.tossFont(20))
            Text(type.value)
                .font(FontManager.shared.font(.semiBold, 14))
                .foregroundStyle(selectedType == type ? Color.basicDark : Color.gray102)
            
        }.padding(.leading)
    }
}

    
#Preview {
    ContentView()
}

