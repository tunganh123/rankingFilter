//
//  InterAdsManager.swift
//  AdsMediationManager
//
//  Created by Admin on 24/10/2023.
//

import Foundation
import SwiftyStoreKit
import Qonversion

open class PaymentManager {
    
    public static let shared: PaymentManager = PaymentManager()
    public static let paymentStateChanged = Notification.Name("paymentStateChanged")
    
    public var productIds: [String] = []
    public var secretKey: String = ""
    var handlePurchase: ((Bool, String) -> ())?

    public func isPremium() -> Bool{
//        
//        return true
//        
        if UserDefaults.standard.bool(forKey: "upgradeToPremiumAll"){
            return true
        }
        
        if let expriedTime = UserDefaults.standard.value(forKey: "upgradeToPremium") as? TimeInterval{
            let nowTime = Date().timeIntervalSince1970
            if nowTime > expriedTime{
                return false
            }
            return true
        }
        return false
    }
    
    public func isExpried() -> Bool{
        if let expriedTime = UserDefaults.standard.value(forKey: "upgradeToPremium") as? TimeInterval{
            let nowTime = Date().timeIntervalSince1970
            if nowTime > expriedTime{
                return true
            }
            return false
        }
        return false
    }

    public func upgradeToPremium(expriredTime: TimeInterval){
        UserDefaults.standard.setValue(expriredTime, forKey: "upgradeToPremium")
        NotificationCenter.default.post(name: PaymentManager.paymentStateChanged, object: nil)
    }
    
    public func upgradeToPremiumAll(){
        UserDefaults.standard.setValue(true, forKey: "upgradeToPremiumAll")
        NotificationCenter.default.post(name: PaymentManager.paymentStateChanged, object: nil)
    }
}

//MARK: Init SDK

extension PaymentManager{
    
    public func initPayment(productIds: [String], secretKey: String){
        self.productIds = productIds
        self.secretKey = secretKey
        
        SwiftyStoreKit.completeTransactions(atomically: true) { results in
            for pItem in results{
                if pItem.transaction.transactionState == .restored ||
                    pItem.transaction.transactionState == .purchased{
                    if pItem.needsFinishTransaction{
                        QonversionSwift.shared.syncStoreKit2Purchases()
                        SwiftyStoreKit.finishTransaction(pItem.transaction)
                    }
                }
            }
        }
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { result1, result2 in
            print(result1)
            print(result2)
            return true
        }

    }
}

//MARK: Normal Purchase

extension PaymentManager{
    
    public func startNormalPurchase(id: String, completion: @escaping ((Bool,String) -> ())) {
        SwiftyStoreKit.purchaseProduct(id, atomically: true) { resutls in
            QonversionSwift.shared.syncStoreKit2Purchases()
            switch resutls {
            case .success:
                PaymentManager.shared.upgradeToPremiumAll()
                completion(true, "")
            case .error(let error):
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    public func restoreNormalPurchase(ids: [String] ,completion: @escaping ((Bool,String) -> ())){
        SwiftyStoreKit.restorePurchases { result in
            if result.restoreFailedPurchases.count > 0{
                completion(false, "You have never paid for this item.")
            }else{
                let storeIds = result.restoredPurchases.map { $0.productId }
                var check = false
                for item in ids{
                    if storeIds.contains(item){
                        check = true
                        break
                    }
                }
                if check{
                    PaymentManager.shared.upgradeToPremiumAll()
                    completion(true, "Success, congratulations on being a VIP member!")
                }else{
                    completion(false, "You have never paid for this item.")
                }
            }
        }
    }
}

//MARK: Subscription Purchase

extension PaymentManager{
    
    public func startSubscriptionPurchase(id: String, completion: @escaping ((Bool,String) -> ())) {
        handlePurchase = completion
        SwiftyStoreKit.purchaseProduct(id, atomically: true) { resutls in
            QonversionSwift.shared.syncStoreKit2Purchases()
            switch resutls {
            case .success:
                self.checkSubscriptionAuto()
            case .error(let error):
                print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    public func restoreSubscriptionPurchase(completion: @escaping ((Bool,String) -> ())){
        handlePurchase = completion
        checkSubscriptionAuto()
    }
    
    private func checkSubscriptionAuto() {
        let receiptValidator = AppleReceiptValidator(service: .production, sharedSecret: secretKey)
        SwiftyStoreKit.verifyReceipt(using: receiptValidator) { [weak self] vresults in
            switch vresults {
            case .success(let receipt):
                self?.verifySubscriptionAuto(receiptInfo: receipt)
            case .error:
                self?.checkSubscriptionAutoSanbox()
            }
        }
    }

    private func checkSubscriptionAutoSanbox() {
        let receiptValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: secretKey)
        SwiftyStoreKit.verifyReceipt(using: receiptValidator) { [weak self] vresults in
            switch vresults {
            case .success(let receipt):
                self?.verifySubscriptionAuto(receiptInfo: receipt)
            case .error(let error):
                self?.handlePurchase?(false, error.localizedDescription)
            }
        }
    }

    private func verifySubscriptionAuto(receiptInfo: ReceiptInfo) {
        let inAppIds = Set(productIds)
        let inAppItems = SwiftyStoreKit.verifySubscriptions(productIds: inAppIds, inReceipt: receiptInfo)
        switch inAppItems {
        case .purchased(let expiryDate, _):
            let time = expiryDate.timeIntervalSince1970
            PaymentManager.shared.upgradeToPremium(expriredTime: time)
            handlePurchase?(true, "")
            print("Payment verify ok")
        case .expired(let expiryDate, _):
            let format = DateFormatter()
            format.dateFormat = "MMM dd, yyyy"
            let dateString = format.string(from: expiryDate)
            handlePurchase?(false, "Your payment has expired from \(dateString)")
            print("Your payment has expired from \(dateString)")
        case .notPurchased:
            handlePurchase?(false, "You have never paid for this item")
            print("You have never paid for this item")
        }
    }
}
