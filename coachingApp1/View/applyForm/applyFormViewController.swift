//
//  applyFormViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/08/17.
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

class applyFormViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, SKProductsRequestDelegate,SKPaymentTransactionObserver {
        
    var myProduct:SKProduct?
    var purchaseExpiresDate: Int?
    
    let imagePickerController = UIImagePickerController()
    var videoURL: URL?
    var cloudVideoURL: String?
    var cloudImageURL: String?
    var currentAsset: AVAsset?
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    var currentTextField = UITextField()
    var currentTextView = UITextView()
    var segueNumber: Int?
    let refreshControl = UIRefreshControl()
    let Ref = Database.database().reference()
    
    var answerFlagArray = [String]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameHidden: UIButton!
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textValidate: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet var closePageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        loadData()
        fetchProducts()
        fetchPurchaseStatus()
        chechApplyNumber()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadData(){
        nameLabel.text = currentUserName
        memo.delegate = self
        textValidate.isHidden = true
        self.PlayButton.isHidden = true
    }
    
    @IBAction func selectedImage(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        //imagePickerController.mediaTypes = ["public.image", "public.movie"]
        imagePickerController.delegate = self
        //動画だけ
        imagePickerController.mediaTypes = ["public.movie"]
        //画像だけ
        //imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
        print("選択できた！")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("yes！")
        self.PlayButton.isHidden = false
        videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        imageView.image = previewImageFromVideo(videoURL!)!
        imageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        print("動画からサムネイルを生成する")
        let asset = AVAsset(url:url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value,0)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            data = image.pngData()
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    
    @IBAction func playMovie(_ sender: Any) {
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        }
    }
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ResultView") {
            
        }else{
            //            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            //            let vc = storyboard.instantiateViewController(withIdentifier: "popoverVC") as! PopoverViewController
            //            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            //            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            //            popover.delegate = self
            //            if sender != nil {
            //                if let button = sender {
            //                    popover.sourceRect = (button as! UIButton).bounds
            //                    popover.sourceView = (sender as! UIView)
            //                }
            //            }
            //            self.present(vc, animated: true, completion:nil)
        }
    }
    
    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // .noneを設定することで、設定したサイズでポップアップされる
        return .none
    }
    
    func fetchPurchaseStatus(){
        purchaseExpiresDate = 2013040326
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int ?? 0
            self.purchaseExpiresDate = key
        })
        
        //        let data = ["purchase":latestExpireDate]
        //        ref.updateChildValues(data)
        
    }
    func fetchProducts(){
        let productIdentifier:Set = ["com.coachingApp.AutoRenewingSubscription1"]
        // 製品ID
        let productsRequest: SKProductsRequest = SKProductsRequest.init(productIdentifiers: productIdentifier)
        productsRequest.delegate = self
        productsRequest.start()
        
    }
    //    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    //        for product in response.products {
    //            let payment: SKPayment = SKPayment(product: product)
    //            SKPaymentQueue.default().add(payment)
    //            print(payment)
    //        }
    //    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first{
            myProduct = product
            print(myProduct)
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
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
            @unknown default:
                break
            }
        }
    }
    //    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    //        for transaction:SKPaymentTransaction in transactions {
    //            switch transaction.transactionState {
    //            case SKPaymentTransactionState.purchasing:
    //                print("課金が進行中")
    //            case SKPaymentTransactionState.deferred:
    //                print("課金が遅延中")
    //            case SKPaymentTransactionState.failed:
    //                print("課金に失敗")
    //                queue.finishTransaction(transaction)
    //            case SKPaymentTransactionState.purchased:
    //                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
    //                print("購入に成功")
    //                queue.finishTransaction(transaction)
    //                self.sendData()
    //            case SKPaymentTransactionState.restored:
    //                print("リストア")
    //                queue.finishTransaction(transaction)
    //                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
    //                self.sendData()
    //            @unknown default:
    //                print("error")
    //            }
    //        }
    //    }
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
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
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
                self.sendData()
            } catch let error {
                print("SKPaymentManager : Failure to validate receipt: \(error)")
            }
        })
        task.resume()
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
        //        self.dismiss(animated: true, completion: nil)
    }
    func restore() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func chechApplyNumber(){
        Ref.child("myApply").child("\(self.currentUid)").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["answerFlag"] as? String {
                        if key == "0"{
                            self.answerFlagArray.append(key)
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func sendVideo(_ sender: Any) {
        textValidate.isHidden = true
        
        if self.videoURL == nil{
            textValidate.isHidden = false
            textValidate.text = "動画を選択してください"
            return
        }
        
        if self.answerFlagArray.count >= 3{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "アドバイスが返ってきていない申請が３つ以上あります。しばらくお待ちください。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "この内容で送信します。よろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                self.closePageButton.isEnabled = false
                self.sendData()
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
    
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func sendData(){
        print("sendData")
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let timenow = formatter.string(from: now as Date)
        let date1 = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let date = formatter1.string(from: date1)
        let date2 = Date()
        let formatter2 = DateFormatter()
        formatter2.setLocalizedDateFormatFromTemplate("jm")
        let time = formatter2.string(from: date2)
        
        //ここから動画DB格納定義
        if self.videoURL != nil{
            self.segueNumber = 1
            let storageReference = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(timenow)"+"_"+"\(self.nameLabel.text!)").child("\(timenow)"+"_"+"\(self.nameLabel.text!).mp4")
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            /// create a temporary file for us to copy the video to.
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(self.videoURL!.lastPathComponent )
            /// Attempt the copy.
            do {
                try FileManager().copyItem(at: self.videoURL!.absoluteURL, to: temporaryFileURL)
            } catch {
                print("There was an error copying the video file to the temporary location.")
            }
            print("\(temporaryFileURL)")
            storageReference.putFile(from: temporaryFileURL, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("error")
                    return
                    
                }
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                // You can also access to download URL after upload.
                storageReference.downloadURL { (url, error) in
                    self.cloudVideoURL = url?.absoluteString
                    print("cloudVideoURL:\(self.cloudVideoURL!)")
                    let applyData = ["cloudVideoURL":"\(self.cloudVideoURL!)" as Any] as [String : Any]
                    let ref0 = self.Ref.child("apply").child("\(timenow)"+"_"+"\(self.nameLabel.text!)")
                    let ref1 = self.Ref.child("myApply").child("\(self.currentUid)").child("\(timenow)"+"_"+"\(self.nameLabel.text!)")
                    ref0.updateChildValues(applyData)
                    ref1.updateChildValues(applyData)
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
            }
            let storageReferenceImage = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(timenow)"+"_"+"\(self.nameLabel.text!)").child("\(timenow)"+"_"+"\(self.nameLabel.text!).png")
            storageReferenceImage.putData(self.data!, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("error")
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                // You can also access to download URL after upload.
                storageReference.downloadURL { (url, error) in
                    //                    self.cloudImageURL = url?.absoluteString
                    //                    print("cloudImageURL:\(self.cloudImageURL!)")
                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
            }
        }else{
            self.segueNumber = 0
        }
        if self.memo.text == ""{
            self.memo.text = "コメントなし"
        }
        let applyData = ["applyID":"\(timenow)"+"_"+"\(self.nameLabel.text!)","uid":"\(self.currentUid)","userName":"\(self.nameLabel.text!)","memo":"\(self.memo.text!)","answerFlag":"0","goodButton":"0","badButton":"0","date":"\(date)","time":"\(time)" as Any] as [String : Any]
        let fcmData = ["fcmTrigger":"0"]
        let ref0 = self.Ref.child("apply").child("\(timenow)"+"_"+"\(self.nameLabel.text!)")
        let ref1 = self.Ref.child("myApply").child("\(self.currentUid)").child("\(timenow)"+"_"+"\(self.nameLabel.text!)")
        let ref2 = self.Ref.child("myApply").child("\(self.currentUid)").child("\(timenow)"+"_"+"\(self.nameLabel.text!)").child("fcmTrigger")
        
        ref0.updateChildValues(applyData)
        ref1.updateChildValues(applyData)
        ref2.updateChildValues(fcmData)
        performSegue(withIdentifier: "resultView", sender: nil)
    }
}
