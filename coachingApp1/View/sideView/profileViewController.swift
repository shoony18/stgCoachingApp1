
//
//  profileViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/05/04.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class profileViewController: UIViewController {
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let currentUserEmail:String = Auth.auth().currentUser!.email!

    var window: UIWindow?

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profileAge: UILabel!
    @IBOutlet weak var profilePrefecture: UILabel!
    @IBOutlet weak var profileSpeciality: UILabel!
    @IBOutlet weak var profileNotification: UILabel!
    @IBOutlet weak var UISwitch: UISwitch!
    @IBOutlet weak var shadowView: UILabel!
    @IBOutlet weak var logoutView: UIButton!

    override func viewDidLoad() {
                
        profile()

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
        /// 画面再表示
     override func viewWillAppear(_ animated: Bool) {
        profile()
         super.viewWillAppear(animated)
     }

    func profile(){
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

//        let dbRef = Database.database().reference().child("fcmToken").child(currentUid)
//        dbRef.observeSingleEvent(of: .value, with: { (snapshot) in
//          // Get user value
//          let value = snapshot.value as? NSDictionary
//          let key = value?["fcmTokenStatus"] as? String ?? ""
//            if key == "1"{
//                self.UISwitch.isOn = true
//                self.profileNotification.text = "ON"
//            }else{
//                self.UISwitch.isOn = false
//                self.profileNotification.text = "OFF"
//            }
//
//          // ...
//          }) { (error) in
//            print(error.localizedDescription)
//        }

    }
        
//    @IBAction func logoutView(_ sender: Any) {
//
//                let alert: UIAlertController = UIAlertController(title: "確認", message: "ログアウトしていいですか？", preferredStyle:  UIAlertController.Style.alert)
//
//                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
//                    (action: UIAlertAction!) -> Void in
//
//                    do{
//                        try Auth.auth().signOut()
////                        self.presentingViewController?.dismiss(animated: true, completion: nil)
//
//                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//                        self.window = UIWindow(frame: UIScreen.main.bounds)
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let initialViewController = storyboard.instantiateViewController(withIdentifier:"loginView")
//                        self.window?.rootViewController = initialViewController
//                        self.window?.makeKeyAndVisible()
//
//                    }catch let error as NSError{
//                        print(error)
//                    }
//                    print("OK")
//                })
//                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
//                    (action: UIAlertAction!) -> Void in
//                    print("Cancel")
//                })
//                alert.addAction(cancelAction)
//                alert.addAction(defaultAction)
//                present(alert, animated: true, completion: nil)
//            
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
