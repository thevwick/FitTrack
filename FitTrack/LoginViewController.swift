//
//  LoginViewController.swift
//  FitTrack
//  Reference: https://github.com/ashishkakkad8/FireSwiftAuthentication
//  Created by Ash  on 20/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordText.isSecureTextEntry = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Handler for login button press
    @IBAction func loginPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.message.text = ""
        
        //Uses firebases' sign in function
        Auth.auth().signIn(withEmail: self.userNameText.text!, password: self.passwordText.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.message.text = error.localizedDescription
            }
            else if let user = user {
                print(user)
                self.message.text = "Login Successful"
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        }
    }
    


}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
