//
//  SignOutViewController.swift
//  FitTrack
//
//  Created by Ash  on 20/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit
import Firebase

class SignOutViewController: UIViewController {
    //When this page is loaded the user is signed out from firestore
    override func viewDidLoad() {
        super.viewDidLoad()
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "signOut", sender: nil)
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
