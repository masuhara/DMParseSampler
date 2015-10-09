//
//  SignInViewController.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/10/09.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var signInIDTextField: UITextField!
    @IBOutlet var signInPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signInIDTextField.delegate = self
        self.signInPasswordTextField.delegate = self
        self.signInPasswordTextField.secureTextEntry = true
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        /*
        UIView.animateWithDuration(0.2, delay: 0.0, options: nil, animations: {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 150)
        }, completion: nil)
        */
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        /*
        UIView.animateWithDuration(0.2, delay: 0.0, options: nil, animations: {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + 150)
        }, completion: nil)
        */
    }
    
    // MARK: Private
    @IBAction func login() {
        SVProgressHUD.showWithStatus("ログイン中...", maskType: SVProgressHUDMaskType.Black)
        PFUser.logInWithUsernameInBackground(self.signInIDTextField.text!, password: self.signInPasswordTextField.text!) {
            (user, error) -> Void in
            if user != nil {
                PFPush.subscribeToChannelInBackground((PFUser.currentUser()?.username!)!, block: { (success, error) -> Void in
                    if success == true {
                        SVProgressHUD.showSuccessWithStatus("ログイン成功!", maskType: SVProgressHUDMaskType.Black)
                    }else {
                        SVProgressHUD.showErrorWithStatus("ログイン失敗!", maskType: SVProgressHUDMaskType.Black)
                    }
                })
                self.dismissViewControllerAnimated(true, completion: nil)
            }else {
                print("not existed user")
                self.showAlert(error!)
                //self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func showAlert(error: NSError) {
        
        var message: String = error.description
        
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
        
        if error.code == 101 {
            message = "ユーザーが見つかりませんでした。IDとパスワードを再確認してログインして下さい。"
        }
        
        if objc_getClass("UIAlertController") != nil {
            let alertController = UIAlertController(title: "ログインエラー", message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Cancel) {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // UIAlertView
            let alertView = UIAlertView(title: "ログインエラー", message: message, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    @IBAction func backToTop() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}