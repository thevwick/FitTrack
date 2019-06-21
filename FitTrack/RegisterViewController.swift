//
//  RegisterViewController.swift
//  FitTrack
//  Reference: https://github.com/ashishkakkad8/FireSwiftAuthentication
//  Created by Ash  on 20/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var passWordText: UITextField!
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var message: UILabel!
    override func viewDidLoad() {
        
        super.viewDidLoad()
       self.passWordText.isSecureTextEntry = true
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
 
    //Handler for when the register button is pressed
    @IBAction func registerPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.message.text = ""
        
        //uses firebases' create user function
        Auth.auth().createUser(withEmail: self.userText.text!, password: self.passWordText.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.message.text = error.localizedDescription
            }
            else if let user = user {
                print(user)
                self.performSegue(withIdentifier: "returnLogin", sender: nil)
            }
        }
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
