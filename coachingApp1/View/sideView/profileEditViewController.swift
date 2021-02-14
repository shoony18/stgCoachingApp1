//
//  profileEditViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/05/07.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MobileCoreServices
import AssetsLibrary


class profileEditViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate, UIScrollViewDelegate,UITextViewDelegate {
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!
    var pickerview0: UIPickerView = UIPickerView()
    var pickerview1: UIPickerView = UIPickerView()
    var pickerview2: UIPickerView = UIPickerView()
    var selectedAge:[String] = []
    var selectedPrefecture:[String] = []
    var selectedSpeciality:[String] = []
    var currentTextField = UITextField()

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profileAge: UITextField!
    @IBOutlet weak var profilePrefecture: UITextField!
    @IBOutlet weak var profileSpeciality: UITextField!
    @IBOutlet weak var saveButton: UIButton!

        
        override func viewDidLoad() {
//            profileName.text = currentUserName
//            profileEmail.text = currentUserEmail
            selectedAge = ["","7","8","9","10","11","12","13","14","15","16","17","18"]
            selectedPrefecture = ["","北海道","青森","岩手","宮城","秋田","山形","福島","茨城","栃木","群馬","埼玉","千葉","東京","神奈川","新潟","富山","石川","福井","山梨","長野","岐阜","静岡","愛知","三重","滋賀","京都","大阪","兵庫","奈良","和歌山","鳥取","島根","岡山","広島","山口","徳島","香川","愛媛","高知","福岡","佐賀","長崎","熊本","大分","宮崎","鹿児島","沖縄"]
            selectedSpeciality = ["","短距離","中距離","長距離","ハードル","跳躍","投擲","混成","競歩","その他"]

            pickerview0.delegate = self
            pickerview0.dataSource = self
            pickerview0.tag = 0
            pickerview0.showsSelectionIndicator = true
            pickerview1.delegate = self
            pickerview1.dataSource = self
            pickerview1.tag = 1
            pickerview1.showsSelectionIndicator = true
            pickerview2.delegate = self
            pickerview2.dataSource = self
            pickerview2.showsSelectionIndicator = true
            pickerview2.tag = 2

            // 決定バーの生成
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
            let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
            toolbar.setItems([spacelItem, doneItem], animated: true)

            // インプットビュー設定
            profileAge.inputView = pickerview0
            profilePrefecture.inputView = pickerview1
            profileSpeciality.inputView = pickerview2
            profileAge.inputAccessoryView = toolbar
            profilePrefecture.inputAccessoryView = toolbar
            profileSpeciality.inputAccessoryView = toolbar

            let ref = Database.database().reference().child("user").child("\(currentUid)")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let key = value?["userName"] as? String ?? ""
                if key.isEmpty{
                    self.profileName.text = "-"
                }else{
                    self.profileName.text = key
                }
            })
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let key = value?["email"] as? String ?? ""
                if key.isEmpty{
                    self.profileEmail.text = "-"
                }else{
                    self.profileEmail.text = key
                }
            })
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let key = value?["age"] as? String ?? ""
                if key.isEmpty{
                    self.profileAge.text = "-"
                }else{
                    self.profileAge.text = key
                }
            })
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let key = value?["prefecture"] as? String ?? ""
                if key.isEmpty{
                    self.profilePrefecture.text = "-"
                }else{
                    self.profilePrefecture.text = key
                }
            })
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let key = value?["speciality"] as? String ?? ""
                if key.isEmpty{
                    self.profileSpeciality.text = "-"
                }else{
                    self.profileSpeciality.text = key
                }
            })

            super.viewDidLoad()

        }
        
        @objc func done() {
            self.view.endEditing(true)
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView.tag == 0{
                return selectedAge.count
            } else if pickerView.tag == 1 {
                return selectedPrefecture.count
            } else if pickerView.tag == 2 {
                    return selectedSpeciality.count
            } else {
                return 0
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView.tag == 0 {
                return selectedAge[row]
            } else if pickerView.tag == 1 {
                return selectedPrefecture[row]
            } else if pickerView.tag == 2 {
                    return selectedSpeciality[row]
            } else {
                print("nil")
                return ""
            }
        }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
            if pickerView.tag == 0 {
                return profileAge.text = selectedAge[row]
            } else if pickerView.tag == 1 {
                return profilePrefecture.text = selectedPrefecture[row]
            } else if pickerView.tag == 2 {
                    return profileSpeciality.text = selectedSpeciality[row]
            } else {
            }
        
    }

    @IBAction func saveProfile(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "確認", message: "この情報で保存していいですか？", preferredStyle:  UIAlertController.Style.alert)

                        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in
                            let ref = Database.database().reference().child("user").child("\(self.currentUid)")
                            let data = ["age":"\(self.profileAge.text!)","prefecture":"\(self.profilePrefecture.text!)","speciality":"\(self.profileSpeciality.text!)" as Any] as [String : Any]
                            ref.updateChildValues(data, withCompletionBlock:{error,ref in if error == nil{
                                print("コメントをアップロードしました")
                            }else{
                                }
                            })
                            self.navigationController?.popViewController(animated: true)
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
