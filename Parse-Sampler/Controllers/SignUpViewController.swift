//
//  SignUpViewController.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/10/09.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var userPassTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        userIDTextField.delegate = self
        userPassTextField.delegate = self
        userPassTextField.secureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUp() {
        self.registerUser()
    }
    
    func registerUser() {
        AlertManager.showAlert(.Normal, message: "登録中...")
        let user = PFUser()
        user.username = userIDTextField.text
        user.password = userPassTextField.text
        user.signUpInBackgroundWithBlock { success, error in
            if error == nil {
                user.saveInBackgroundWithBlock { success, error in
                    if success {
                        PFPush.subscribeToChannelInBackground((PFUser.currentUser()?.username)!, block: { success, error in
                            if success == true {
                                AlertManager.showAlert(.Success, message: "登録完了")
                            }else {
                                AlertManager.showAlert(.Error, message: "エラー")
                            }
                        })
                        self.back()
                    }else {
                        AlertManager.showAlert(.Error, message: "エラー")
                    }
                }
            }else {
                let errorMessage = error?.description
                AlertManager.showAlert(.Error, message: errorMessage!)
            }
        }
    }
    
    private func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
