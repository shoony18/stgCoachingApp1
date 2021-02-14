//
//  resultViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/02/14.
//

import UIKit

class resultViewController: UIViewController {
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closePage(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier:"mainView")
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
