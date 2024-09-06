//
//  IAPurchaseManager.swift
//  IAPurchaseManager
//
//  Created by ejsong on 9/2/24.
//

import Foundation
import AppStoreServerLibrary
import JWTDecode

struct InAppModel {
    var issuerId: String  = ""
    var keyId : String    = ""
    var bundleId : String = ""
    var encodedKey : String = ""
    
    init(encodedKey: String) {
        self.encodedKey = encodedKey
    }
    
    init() { }
}


class IAPurchaseManager : NSObject {
    static let shared = IAPurchaseManager()
    
    var environment : Environment = .production
    
    var client : AppStoreServerAPIClient?
    var model : InAppModel?
    
    override init() {
        super.init()
        model = getEncodedKey()
        reqChangeClient(of: environment)
    }
    
    func setUp() {
        model = getEncodedKey()
        reqChangeClient(of: environment)
    }
    
    func reqChangeClient(of value: Environment) {
        guard let model = model else { return }
        environment = value
        client = getClient(of: model)
    }
    
    /**
     인증서 내용 추출 후 모델 생성
     */
    private func getEncodedKey() -> InAppModel {
        guard let jsonPath = Bundle.main.path(forResource: "SubscriptionKey_", ofType: "p8") else { return InAppModel() }
        
        let file = try! String(contentsOfFile: jsonPath)
        
        return InAppModel(encodedKey: file)
    }
    
    /**
     client
     */
    func getClient(of model: InAppModel) -> AppStoreServerAPIClient? {
        do {
            let client = try AppStoreServerAPIClient(signingKey: model.encodedKey,
                                                     keyId: model.keyId,
                                                     issuerId: model.issuerId,
                                                     bundleId: model.bundleId,
                                                     environment: environment)
            return client
        }catch {
            print("ERROR :: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     Refund History ( 환불 정보 )
     */
    
    func getRefundHistory(of id: String) async throws -> [OrderLookUpModel] {
        let response = await client?.getRefundHistory(transactionId: id, revision: nil)
        
        switch response {
        case .success(let response):
            do {
                var value : [OrderLookUpModel] = []
                guard let transaction = response.signedTransactions else { return [] }
                
                for i in transaction {
                    let jwt = try decode(jwt: i)
                    let jsonData = try JSONSerialization.data(withJSONObject: jwt.body, options: [])
                    print("refund body :: \(jwt.body)")
                    let model = try JSONDecoder().decode(OrderLookUpModel.self, from: jsonData)
                    value.append(model)
                }
                return value
            }catch {
                return []
            }
            
        case .failure(let statusCode, let rawApiError, let apiError, let errorMessage, let causedBy):
            print("""
                ================================================
                \(#function)
                statusCode   :: \(String(describing: statusCode))
                rawAPIError  :: \(String(describing: rawApiError))
                apiError     :: \(String(describing: apiError))
                errorMessage :: \(String(describing: errorMessage))
                causedBy     :: \(String(describing: causedBy))
                ================================================
                """)
        case .none:
            print("none")
            return []
            
        }
        
        return []
    }
    
    /**
     Look Up Order ID (주문 번호 조회)
     */
    func getLookUpOrderID(of orderID: String) async throws -> [OrderLookUpModel] {
        let response = await client?.lookUpOrderId(orderId: orderID)
        
        switch response {
        case .success(let response):
            do {
                var value : [OrderLookUpModel] = []
                guard let transaction = response.signedTransactions else { return [] }
                
                for i in transaction {
                    let jwt = try decode(jwt: i)
                    let jsonData = try JSONSerialization.data(withJSONObject: jwt.body, options: [])
                    let model = try JSONDecoder().decode(OrderLookUpModel.self, from: jsonData)
                    value.append(model)
                }
                return value
            }catch {
                return []
            }
            
        case .failure(let statusCode, let rawApiError, let apiError, let errorMessage, let causedBy):
            print("""
                ================================================
                \(#function)
                statusCode   :: \(String(describing: statusCode))
                rawAPIError  :: \(String(describing: rawApiError))
                apiError     :: \(String(describing: apiError))
                errorMessage :: \(String(describing: errorMessage))
                causedBy     :: \(String(describing: causedBy))
                ================================================
                """)
        case .none:
            return []
        }
        
        return []
    }
    
    /**
     토큰 가져오기
     */
    func getToken(of model: InAppModel, environment : Environment = .production) async {
        do {
            let client = try AppStoreServerAPIClient(signingKey: model.encodedKey,
                                                      keyId: model.keyId,
                                                      issuerId: model.issuerId,
                                                      bundleId: model.bundleId,
                                                      environment: environment)
            
            let response = await client.requestTestNotification()
            
            switch response {
            case .success(let response):
                print("response :: \(String(describing: response.testNotificationToken))")
            case .failure(let errorCode, let rawApiError, let apiError, let errorMessage, let causedBy):
                print("""
                    \n
                    ================================================
                    errorCode    :: \(String(describing: errorCode))
                    rawAPIError  :: \(String(describing: rawApiError))
                    apiError     :: \(String(describing: apiError))
                    errorMessage :: \(String(describing: errorMessage))
                    causedBy     :: \(String(describing: causedBy))
                    ================================================
                    """)
            }
        }catch {
            print("ERROR :: \(error.localizedDescription)")
        }
    }
    
    /**
     Receipt Usage
     */
    func reqReceipt(of transactionID: String) async throws -> [OrderLookUpModel] {
        
        var transactionHistoryRequest = TransactionHistoryRequest()
        transactionHistoryRequest.sort = .descending
        transactionHistoryRequest.revoked = false
        transactionHistoryRequest.productTypes = [.autoRenewable, .consumable, .nonConsumable, .nonRenewable]
        
        var response: HistoryResponse?
        var transactions: [String] = []
        
        repeat {
            let revisionToken = response?.revision
            let apiResponse = await client?.getTransactionHistory(transactionId: transactionID, revision: revisionToken, transactionHistoryRequest: transactionHistoryRequest, version: .v2)
            
            switch apiResponse {
            case .success(let success):
                
                response = success

            case .failure, .none:
                print("ERROR")
            }
            
            if let signedTransactions = response?.signedTransactions {
                transactions.append(contentsOf: signedTransactions)
            }
            
        }while (response?.hasMore ?? false)

        
        var value : [OrderLookUpModel] = []
  
        for i in transactions {
            let jwt = try decode(jwt: i)
            let jsonData = try JSONSerialization.data(withJSONObject: jwt.body, options: [])
            let model = try JSONDecoder().decode(OrderLookUpModel.self, from: jsonData)
            print("model 111 :: \(jwt.body)")
            value.append(model)
        }
        
        return value
    }
}

