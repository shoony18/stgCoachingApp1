//
//  applyUserRuleViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/10/24.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import FirebaseStorage
import FirebaseMessaging
import Photos
import MobileCoreServices
import AssetsLibrary
import StoreKit

class applyUserRuleViewController: UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    var myProduct:SKProduct?
    var purchaseExpiresDate: Int?
    

    @IBOutlet var ruleText: UILabel!
    @IBOutlet var approveFlagButton: UIButton!
    @IBOutlet var goToButton: UIButton!
    @IBOutlet var closePageButton: UIBarButtonItem!
    
    var approveFlag:Int = 0
    let Ref = Database.database().reference()
    let currentUid:String = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        fetchProducts()
        fetchPurchaseStatus()
        
        goToButton.isEnabled = false
        super.viewDidLoad()
    }
    @IBAction func tapApproveFlagButton(_ sender: Any) {
        if approveFlag == 0{
            approveFlag = 1
            let picture = UIImage(named: "checkFlag_fill")
            self.approveFlagButton.setImage(picture, for: .normal)
            goToButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            goToButton.backgroundColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
            goToButton.isEnabled = true
        }else if approveFlag == 1{
            approveFlag = 0
            let picture = UIImage(named: "checkFlag")
            self.approveFlagButton.setImage(picture, for: .normal)
            goToButton.tintColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
            goToButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            goToButton.isEnabled = false
        }
    }
    
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func fetchPurchaseStatus(){
        purchaseExpiresDate = 2013040326
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int ?? 0
            self.purchaseExpiresDate = key
        })
    }
    func fetchProducts(){
        let productIdentifier:Set = ["com.coachingApp.AutoRenewingSubscription1"]
        // 製品ID
        let productsRequest: SKProductsRequest = SKProductsRequest.init(productIdentifiers: productIdentifier)
        productsRequest.delegate = self
        productsRequest.start()

    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first{
            myProduct = product
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                queue.finishTransaction(transaction)
                print("Transaction Failed \(transaction)")
            case .purchased, .restored:
                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                queue.finishTransaction(transaction)
                print("Transaction purchased or restored: \(transaction)")
                self.performSegue(withIdentifier: "applyFormSegue", sender: nil)
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
//                self.goToButton.setTitle("課金処理中", for: .normal)
//                goToButton.backgroundColor = #colorLiteral(red: 1, green: 0.4506040812, blue: 0.4881162643, alpha: 1)
            @unknown default:
                break
            }
        }
        print("ddd")
    }
    // Appleサーバーに問い合わせてレシートを取得
    func receiptValidation(url: String) {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        let receiptData = try! Data(contentsOf: receiptUrl!)
        
        let requestContents = [
            "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
            "password": "210b06513c2d472f97911611492ee0cb" // appstoreconnectからApp 用共有シークレットを取得しておきます
        ]
        
        let requestData = try! JSONSerialization.data(withJSONObject: requestContents, options: .init(rawValue: 0))
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"content-type")
        request.timeoutInterval = 5.0
        request.httpMethod = "POST"
        request.httpBody = requestData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [self](data, response, error) -> Void in
            
            guard let jsonData = data else {
                return
            }
            
            do {
                let json:Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: jsonData, options: .init(rawValue: 0)) as! Dictionary<String, AnyObject>
                
                let status:Int = json["status"] as! Int
                if status == receiptErrorStatus.invalidReceiptForProduction.rawValue {
                    self.receiptValidation(url: "https://sandbox.itunes.apple.com/verifyReceipt")
                }
                
                guard let receipts:Dictionary<String, AnyObject> = json["receipt"] as? Dictionary<String, AnyObject> else {
                    return
                }
                
                // 機能開放
                self.provideFunctions(receipts: receipts)
            } catch let error {
                print("SKPaymentManager : Failure to validate receipt: \(error)")
            }
            print("aaa")
//            self.goToButton.setTitle("課金処理完了ー質問フォームへ進む", for: .normal)
//            goToButton.backgroundColor = #colorLiteral(red: 0.4393133819, green: 0.8128572106, blue: 0.6976569295, alpha: 1)
//            self.goToButton.isEnabled = true

        })
        task.resume()
        print("ccc")

    }
    enum receiptErrorStatus: Int {
        case invalidJson = 21000
        case invalidReceiptDataProperty = 21002
        case authenticationError = 21003
        case commonSecretKeyMisMatch = 21004
        case receiptServerNotWorking = 21005
        case invalidReceiptForProduction = 21007
        case invalidReceiptForSandbox = 21008
        case unknownError = 21010
    }
    private func provideFunctions(receipts:Dictionary<String, AnyObject>) {
        let in_apps = receipts["in_app"] as! Array<Dictionary<String, AnyObject>>
        
        var latestExpireDate:Int = 0
        for in_app in in_apps {
            let receiptExpireDateMs = Int(in_app["expires_date_ms"] as? String ?? "") ?? 0
            let receiptExpireDateS = receiptExpireDateMs / 1000
            if receiptExpireDateS > latestExpireDate {
                latestExpireDate = receiptExpireDateS
            }
        }
        UserDefaults.standard.set(latestExpireDate, forKey: "expireDate")
        print(latestExpireDate)
        let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"プレミアム課金中"] as [String : Any]
        let ref = self.Ref.child("user").child("\(self.currentUid)")
        ref.updateChildValues(data)
        print("bbb")

        //        self.dismiss(animated: true, completion: nil)
    }
    func restore() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    @IBAction func tappedButton(_ sender: Any) {
            let alert: UIAlertController = UIAlertController(title: "確認", message: "プレミアムコーチングサービスに加入しますか？初回2週間無料トライアル、以降月額980円です。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                self.closePageButton.isEnabled = false
//                self.goToButton.isEnabled = false
                self.goToButton.setTitle("課金処理準備中", for: .normal)
                goToButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                goToButton.backgroundColor = #colorLiteral(red: 0.3729103804, green: 0.6191056967, blue: 0.9580503106, alpha: 1)

                guard  let myProduct = self.myProduct else {
                    return
                }
                if SKPaymentQueue.canMakePayments(){
                    let payment = SKPayment(product: myProduct)
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(payment)
                }
            })
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)

        }
}
