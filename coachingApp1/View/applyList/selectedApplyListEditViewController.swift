//
//  selectedApplyListEditViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/11/27.
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

class selectedApplyListEditViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet var memo: UITextView!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var playVideo: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var selectedApplyID: String?
    
    let imagePickerController = UIImagePickerController()
    var videoURL: URL?
    var currentAsset: AVAsset?
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    
    
    let bundleDataType: String = "mp4"
    var text: String?
    var flag: String?
    var cache: String? = "0"
    var selectedspeciality: String?
    var selectedQAContent: String?
    var selectedAnswer: String?
    var selectedUid: String?
    var playUrl:NSURL?
    var attachedUrl:NSURL?
    var selectedSpeciality:[String] = []
    var txtActiveView = UITextView()
    // 現在選択されているTextField
    var selectedTextView:UITextView?
    
    let Ref = Database.database().reference()
    
    override func viewDidLoad() {
        
        textItem()
        loadData()
        download()
        self.contentView.addSubview(ImageView)
        self.contentView.sendSubviewToBack(ImageView);
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func textItem(){
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        memo.inputAccessoryView = toolbar
    }
    @objc func done() {
        self.view.endEditing(true)
    }
    
    func loadData(){
        let ref1 = Ref.child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)")
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["memo"] as? String ?? ""
            self.memo.text = key
        })
        
    }
    @objc func playVideo(_ sender: UIButton) {
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        }else{
            let player = AVPlayer(url: playUrl! as URL
            )

            // Create a new AVPlayerViewController and pass it a reference to the player.
            let controller = AVPlayerViewController()
            controller.player = player

            // Modally present the player and call the player's play() method when complete.
            present(controller, animated: true) {
                controller.player!.play()
            }
        }
    }
    
    func download(){
        
        let textVideo:String = self.selectedApplyID!+".mp4"
        let textImage:String = self.selectedApplyID!+".png"
        let refVideo = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textVideo)")
        print("\(refVideo)")
        refVideo.downloadURL{ url, error in
        if (error != nil) {
            print("QA添付動画なし")
            let imageView: UIImageView = self.ImageView
            // Placeholder image
            let placeholderImage = UIImage(named: "rikujou_track_top.png")
            imageView.image = placeholderImage
        } else {
            self.playUrl = url as NSURL?
            print("download success!! URL:", url!)
            print("QA添付動画あり")
        }
        }
        let refImage = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textImage)")
        ImageView.sd_setImage(with: refImage, placeholderImage: nil)
        playVideo.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)

    }
    
    @IBAction func selectedImage(_ sender: Any) {
        imagePickerController.sourceType = .photoLibrary
        //          //imagePickerController.mediaTypes = ["public.image", "public.movie"]
        imagePickerController.delegate = self
        //動画だけ
        imagePickerController.mediaTypes = ["public.movie"]
        //画像だけ
        //imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        print(videoURL!)
        ImageView.image = previewImageFromVideo(videoURL!)!
        ImageView.contentMode = .scaleAspectFit
        self.cache = "1"
        imagePickerController.dismiss(animated: true, completion: nil)

    }
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        let asset = AVAsset(url:url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value,0)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            // PNG形式の画像フォーマットとしてNSDataに変換
            data = image.pngData()
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    @IBAction func resendQA(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "確認", message: "この内容で送信していいですか？動画の変更は反映されるまでに時間がかかる場合があります。", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
          
            if self.memo.text == ""{
                self.memo.text = "コメントなし"
            }
            let postData = ["memo":"\(self.memo.text!)" as Any] as [String : Any]
            let cacheData = ["cache":"\(self.cache!)" as Any] as [String : Any]

            let ref0 = self.Ref.child("apply").child("\(self.selectedApplyID!)")
            let ref1 = self.Ref.child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)")
            let ref2 = self.Ref.child("user").child("\(self.currentUid)")

            ref0.updateChildValues(postData)
            ref1.updateChildValues(postData)
            ref2.updateChildValues(cacheData)

            let textVideo:String = self.selectedApplyID!+".mp4"
            let textImage:String = self.selectedApplyID!+".png"
            
            if self.cache == "1"{
                let refVideo = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textVideo)")
                refVideo.delete { error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == StorageErrorDomain &&
                            nsError.code == StorageErrorCode.objectNotFound.rawValue {
                        }
                    } else {
                        print("delete success!!")
                    }
                }
                
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
                refVideo.putFile(from: temporaryFileURL, metadata: nil) { metadata, error in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print("error")
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    _ = metadata.size
                    // You can also access to download URL after upload.
                    refVideo.downloadURL { (url, error) in
                        guard url != nil else {
                            // Uh-oh, an error occurred!
                            return
                        }
                    }
                }
                let refImage = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textImage)")
                refImage.delete { error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == StorageErrorDomain &&
                            nsError.code == StorageErrorCode.objectNotFound.rawValue {
                            print("目的の参照にオブジェクトが存在しません")
                        }
                    } else {
                        print("delete success!!")
                    }
                }
                refImage.putData(self.data!, metadata: nil) { metadata, error in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print("error")
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    _ = metadata.size
                    // You can also access to download URL after upload.
                    refImage.downloadURL { (url, error) in
                        guard url != nil else {
                            // Uh-oh, an error occurred!
                            return
                        }
                    }
                }
                
            }
            self.navigationController?.popViewController(animated: true)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{(action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
        
}
