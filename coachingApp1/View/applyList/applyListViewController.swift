//
//  applyListViewController.swift
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

class applyListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var TableView: UITableView!
    
    var applyIDArray = [String]()
    var dateArray = [String]()
    var timeArray = [String]()
    var answerFlagArray = [String]()
    var memoArray = [String]()
    
    var applyIDArray_re = [String]()
    var dateArray_re = [String]()
    var timeArray_re = [String]()
    var eventArray_re = [String]()
    var answerFlagArray_re = [String]()
    var memoArray_re = [String]()
    
    var selectedApplyID: String?
    
    let imagePickerController = UIImagePickerController()
    var cache: String?
    var videoURL: URL?
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    override func viewDidLoad() {
        TableView.dataSource = self
        TableView.delegate = self
        initilize()
        loadData()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.TableView.reloadData()
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
        let ref0 = Ref.child("user").child("\(self.currentUid)")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["cache"] as? String ?? ""
            self.cache = key
            if self.cache == "1"{
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                let data = ["cache":"0" as Any] as [String : Any]
                ref0.updateChildValues(data)
            }
        })

        applyIDArray.removeAll()
        dateArray.removeAll()
        timeArray.removeAll()
        answerFlagArray.removeAll()
        memoArray.removeAll()
        
        applyIDArray_re.removeAll()
        dateArray_re.removeAll()
        timeArray_re.removeAll()
        eventArray_re.removeAll()
        answerFlagArray_re.removeAll()
        memoArray_re.removeAll()
        
        Ref.child("myApply").child("\(self.currentUid)").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["applyID"] as? String {
                        self.applyIDArray.append(key)
                        self.applyIDArray_re = self.applyIDArray.reversed()
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["date"] as? String {
                        self.dateArray.append(key)
                        self.dateArray_re = self.dateArray.reversed()
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["time"] as? String {
                        self.timeArray.append(key)
                        self.timeArray_re = self.timeArray.reversed()
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["answerFlag"] as? String {
                        self.answerFlagArray.append(key)
                        self.answerFlagArray_re = self.answerFlagArray.reversed()
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["memo"] as? String {
                        self.memoArray.append(key)
                        self.memoArray_re = self.memoArray.reversed()
                        self.TableView.reloadData()
                    }
                }
            }
        })
    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applyIDArray_re.count
    }
    
    
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.TableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? applyListTableViewCell
        cell!.title.text = self.memoArray_re[indexPath.row]
        cell!.date.text = self.dateArray_re[indexPath.row]
        cell!.time.text = self.timeArray_re[indexPath.row]
        if self.answerFlagArray_re[indexPath.row] == "1"{
            cell!.status.text = "回答準備中"
            cell!.status.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        }else if self.answerFlagArray_re[indexPath.row] == "2"{
            cell!.status.text = "回答あり"
            cell!.status.backgroundColor = #colorLiteral(red: 0.7781245112, green: 0.1633349657, blue: 0.4817854762, alpha: 1)
        }else{
            cell!.status.text = "回答待ち"
            cell!.status.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        }

        let textImage:String = self.applyIDArray_re[indexPath.row]+".png"
        let refImage = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.applyIDArray_re[indexPath.row])").child("\(textImage)")
        cell!.ImageView.sd_setImage(with: refImage, placeholderImage: nil)
        if indexPath.row == applyIDArray_re.count-1 {
            self.initilizedView.removeFromSuperview()
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedApplyID = applyIDArray_re[indexPath.row]
        performSegue(withIdentifier: "selectedApply", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectedApply") {
            if #available(iOS 13.0, *) {
                let nextData: selectedApplyListViewController = segue.destination as! selectedApplyListViewController
                nextData.selectedApplyID = self.selectedApplyID!
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
