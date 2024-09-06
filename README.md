# 🐾 IAPTracking

> ❗️ 문제점
> 사용자가 인 앱 결제를 통해 결제 후 보상이 제대로 이루어 지지 않은 경우 실 결제 한 항목인지 확인 할 수 있는 로직이 필요 했다.
> AppStoreConnect의 ‘판매 및 추세’에서 판매량 & 수익 & 매출 만 보여줄 뿐, 애플 측에 환불을 받았는지 상세한 내용을 알 수가 없어 
> 따로 연락을 취해 문제를 해결해야 했다.

> ✨ 해결 방안
> App Store Server API 를 통해 주문 번호 or Transaction ID 값으로 주문 내역, 환불 내역을 조회 할 수 있다. 

## 1. AppStoreServerAPIClient 조회
```Swift
do {
    let client = try AppStoreServerAPIClient(signingKey : ENCODED_KEY, //발급 받은 SubscriptionKey.p8을 인코딩한 String 값
                                             keyId      : KEY_ID,      //AppStoreConnect > 사용자 및 엑세스 > Subscription Key ID (권한 없으면 안보일 수 있음)
                                             issuerId   : ISSUER_ID,   //AppStoreConnect > 사용자 및 엑세스 > issuer ID          (권한 없으면 안보일 수 있음)
                                             bundleId   : BUNDLE_ID,   //프로젝트 번들 ID
                                             environment: ENVIRONMENT) //.xCode, .localTesting, .Production (실서버), .sandBox (개발)
    return client
}catch {
    return nil
}
```

## 2. 구매 조회 by Order ID
```Swift
// 여기서 client 는 위에 AppStoreServerAPIClient에서 리턴된 값이다.
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
```

## 2 - 1 구매 조회 by Transaction ID 
```Swift
var transactionHistoryRequest          = TransactionHistoryRequest()
transactionHistoryRequest.sort         = .descending
transactionHistoryRequest.revoked      = false
transactionHistoryRequest.productTypes = [.autoRenewable, .consumable, .nonConsumable, .nonRenewable]

var response: HistoryResponse?
var transactions: [String] = []

repeat {
    let revisionToken = response?.revision
    let apiResponse = await client?.getTransactionHistory(transactionId: transactionID, 
                                                          revision: revisionToken, 
                                                          transactionHistoryRequest: transactionHistoryRequest, 
                                                          version: .v2)
    
    switch apiResponse {
    case .success(let success): response = success
    case .failure, .none: print("ERROR")
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
    value.append(model)
}

return value
```

## 3. 환불 조회
```Swift
let response = await client?.getRefundHistory(transactionId: id, revision: nil)

switch response {
case .success(let response):
    do {
        var value : [OrderLookUpModel] = []
        guard let transaction = response.signedTransactions else { return [] }
        
        for i in transaction {
            let jwt      = try decode(jwt: i)
            let jsonData = try JSONSerialization.data(withJSONObject: jwt.body, options: [])
            let model    = try JSONDecoder().decode(OrderLookUpModel.self, from: jsonData)
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
```
