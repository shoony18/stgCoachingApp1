//
//  MenuViewController.swift
//
//  Created by 刈田修平 on 2020/11/21.
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

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var menuArray = ["プロフィール情報","利用規約"]
    var purchaseExpiresDate: Int?

    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    @IBOutlet var menuView: UIView!
    @IBOutlet var TableView: UITableView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var purchaseStatus: UILabel!
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let Ref = Database.database().reference()

    override func viewDidLoad() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        loadData()
        initilize()
        TableView.dataSource = self
        TableView.delegate = self
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.TableView.reloadData()
        super.viewWillAppear(animated)
        
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

    func loadData(){
        
        self.purchaseStatus.text = "課金なし"
        self.purchaseStatus.backgroundColor = #colorLiteral(red: 0.01579796895, green: 0.756948173, blue: 0.4846590757, alpha: 1)
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["userName"] as? String ?? ""
            let key2 = value?["purchaseStatus"] as? String ?? ""
            let key3 = value?["purchaseExpiresDate"] as? Int ?? 0
            self.userName.text = "ようこそ、 "+"\(key1)"+" さん"
            let timeInterval = NSDate().timeIntervalSince1970
            if Int(timeInterval) < key3 {
                self.purchaseStatus.text = key2
                self.purchaseStatus.backgroundColor = #colorLiteral(red: 0.9977573752, green: 0.4582185745, blue: 0.4353175163, alpha: 1)
            }else{
                let data = ["purchaseStatus":"課金なし"] as [String : Any]
                let ref = self.Ref.child("user").child("\(self.currentUid)")
                ref.updateChildValues(data)
            }
            self.initilizedView.removeFromSuperview()
        })
    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
                
       
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath as IndexPath) as? menuTableViewCell
        cell!.menu.text = self.menuArray[indexPath.row]
        return cell!
    }
        

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "myProfile", sender: nil)
        }else if indexPath.row == 1{
            performSegue(withIdentifier: "appRule", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    }

    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
    }
}
