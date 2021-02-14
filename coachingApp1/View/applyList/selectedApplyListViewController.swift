//
//  selectedApplyListViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/10/04.
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
import SDWebImage

class selectedApplyListViewController: UIViewController, UITextViewDelegate{
    
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var memo: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var answerFlag: UILabel!
    @IBOutlet var ImageView: UIImageView!

    @IBOutlet var answerTitle: UILabel!
    @IBOutlet var goodPoint: UILabel!
    @IBOutlet var badPoint: UILabel!
    @IBOutlet var practice: UILabel!
    @IBOutlet var sankouURL: UITextView!
    @IBOutlet var comment: UILabel!
    
    var selectedApplyID: String?
            
    let imagePickerController = UIImagePickerController()
    var cache: String?
    var videoURL: URL?
    var playUrl:NSURL?
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    override func viewDidLoad() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        initilize()
        loadDataApply()
        download()
        loadDataAnswer()
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
        }
    }
    
    func initilize(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        initilizedView.frame = CGRect.init(x: 0, y: 0, width: viewWidth, height: viewHeight)
        initilizedView.backgroundColor = .white
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.color = .gray
        ActivityIndicator.startAnimating()

        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true

        //Viewに追加
        initilizedView.addSubview(ActivityIndicator)
        view.addSubview(initilizedView)
    }

    func loadDataApply(){
        
        let ref = Ref.child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["userName"] as? String ?? ""
            self.userName.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["memo"] as? String ?? ""
            self.memo.text = key
            
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["date"] as? String ?? ""
            self.date.text = key
            
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["time"] as? String ?? ""
            self.time.text = key
            
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["answerFlag"] as? String ?? ""
            if key == "1"{
                self.answerFlag.text = "回答準備中"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
                self.answerTitle.text = "まだ回答はありません"
            }else if key == "2"{
                self.answerFlag.text = "回答あり"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.7781245112, green: 0.1633349657, blue: 0.4817854762, alpha: 1)
                self.answerTitle.text = "回答"
            }else{
                self.answerFlag.text = "回答待ち"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
                self.answerTitle.text = "まだ回答はありません"
            }
        })
        let textImage:String = self.selectedApplyID!+".png"
        let refImage = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textImage)")
        ImageView.sd_setImage(with: refImage, placeholderImage: nil)
        
    }
    func loadDataAnswer(){
        let ref = Ref.child("answer").child("\(self.selectedApplyID!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["good"] as? String ?? ""
            self.goodPoint.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["bad"] as? String ?? ""
            self.badPoint.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["practice"] as? String ?? ""
            self.practice.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["URL"] as? String ?? ""
            self.sankouURL.text = key
            let attributedString = NSMutableAttributedString(string: key)
            attributedString.addAttribute(.link,
                                          value: key,
                                          range: NSString(string: key).range(of: key))
            self.sankouURL.attributedText = attributedString
            // isSelectableをtrue、isEditableをfalseにする必要がある
            // （isSelectableはデフォルトtrueだが説明のため記述）
            self.sankouURL.isSelectable = true
            self.sankouURL.isEditable = false
            self.sankouURL.delegate = self as UITextViewDelegate
            print("sankouURL")
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["comment"] as? String ?? ""
            self.comment.text = key
        })
        
    }
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {

        UIApplication.shared.open(URL)

        return false
    }
    @objc func playVideo(_ sender: UIButton) {
        let player = AVPlayer(url: playUrl! as URL
        )
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        present(controller, animated: true) {
            controller.player!.play()
        }
    }
    
    func download(){
        
        let textVideo:String = selectedApplyID!+".mp4"
        let refVideo = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textVideo)")
        refVideo.downloadURL{ url, error in
            if (error != nil) {
            } else {
                self.playUrl = url as NSURL?
                print("download success!! URL:", url!)
            }
        }
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["cache"] as? String ?? ""
            self.cache = key
            if self.cache == "1"{
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                let data = ["cache":"0" as Any] as [String : Any]
                ref.updateChildValues(data)
            }
            self.initilizedView.removeFromSuperview()
        })
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if answerFlag.text == "回答待ち"{
            if (segue.identifier == "selectedApplyEdit") {
                if #available(iOS 13.0, *) {
                    let nextData: selectedApplyListEditViewController = segue.destination as! selectedApplyListEditViewController
                    nextData.selectedApplyID = self.selectedApplyID!
                } else {
                    // Fallback on earlier versions
                }
            }
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "回答準備中またはアドバイスを既にもらっているため申請内容を編集できません", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
}
