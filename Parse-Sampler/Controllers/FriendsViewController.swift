//
//  FriendsViewController.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/10/08.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var friendArray = [AnyObject]()
    var requestArray = [AnyObject]()
    var pendingArray = [AnyObject]()
    var userArray = [AnyObject]()
    @IBOutlet var friendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendTableView.dataSource = self
        self.friendTableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() == nil {
            self.performSegueWithIdentifier("toSignIn", sender: nil)
        }else {
            self.loadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.friendArray.count
        case 1:
            return self.requestArray.count
        case 2:
            return self.pendingArray.count
        default :
            return self.userArray.count
        }
    }
    
    // MARK: TableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "友達一覧"
        case 1:
            return "友達リクエスト一覧"
        case 2:
            return "申請中"
        default :
            return "友達ですか?"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as UITableViewCell!
        
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = self.friendArray[indexPath.row] as? String
            break
        case 1:
            cell.textLabel!.text = self.requestArray[indexPath.row] as? String
            break
        case 2:
            cell.textLabel!.text = self.pendingArray[indexPath.row] as? String
            break
        default :
            cell.textLabel!.text = self.userArray[indexPath.row]["username"] as? String
            break
        }
        
        return cell
    }
    
    // MARK: TableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        }else if indexPath.section == 1 {
            
        }else {
            let alertController = UIAlertController(title: "友達申請", message: "友達申請しますか?", preferredStyle: .Alert)
            let otherAction = UIAlertAction(title: "申請", style: .Default) {
                action in
                self.follow(indexPath)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel) {
                action in
                // canceled
            }
            alertController.addAction(otherAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Get data from Parse
    func loadData() {
        
        self.friendArray = [AnyObject]()
        self.requestArray = [AnyObject]()
        self.pendingArray = [AnyObject]()
        self.userArray = [AnyObject]()
        
        let usersData: PFQuery = PFQuery(className: "_User")
        usersData.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
        usersData.findObjectsInBackgroundWithBlock { objects, error in
            if error != nil {
                print(error)
            }else {
                for object in objects! {
                    self.userArray.append(object)
                    for friend in object["friends"] as! NSArray {
                        self.friendArray.append(friend)
                    }
                    for request in object["requests"] as! NSArray {
                        self.requestArray.append(request)
                    }
                    for pending in object["pending"] as! NSArray {
                        self.pendingArray.append(pending)
                    }
                }
                self.friendTableView.reloadData()
            }
        }
    }
    
    func follow(indexPath: NSIndexPath) {
        let object = self.userArray[indexPath.row] as! PFUser
        let currentUser = PFUser.currentUser()!
        currentUser.addUniqueObject(object.objectId!, forKey: "pending")
        currentUser.saveInBackgroundWithBlock { succeeded, error in
            if succeeded == true {
                AlertManager.showAlert(.Success, message: "友達申請しました")
                let message = String(format: "%@から友達リクエストが届きました", (PFUser.currentUser()?.username)!)
                let data = ["alert": message, "sound": "default", "badge": "Increment"]
                do {
                    try PFPush.sendPushDataToChannel(object.username!, withData: data)
                }catch {
                    print("error")
                }
            }else {
                NSLog("エラー %@", error!.description)
                SVProgressHUD.showErrorWithStatus(error?.description)
            }
        }
    }
    
    @IBAction func signOut() {
        PFUser.logOutInBackgroundWithBlock { error in
            do {
                try PFUser.currentUser()?.delete()
                AlertManager.showAlert(.Success, message: "ログアウトしました")
                self.performSegueWithIdentifier("toSignIn", sender: nil)
            }catch {
                AlertManager.showAlert(.Error, message: "サインアウト出来ません")
            }
        }
    }
}
