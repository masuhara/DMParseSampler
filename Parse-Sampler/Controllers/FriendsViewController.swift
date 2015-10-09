//
//  FriendsViewController.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/10/08.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var pendingArray = [AnyObject]()
    var friendArray = [AnyObject]()
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
            return self.pendingArray.count
        case 1:
            return self.friendArray.count
        default :
            return self.friendArray.count
        }
    }
    
    // MARK: TableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "友達申請"
        case 1:
            return "友達一覧"
        default :
            return "友達ですか?"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as UITableViewCell!
        
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = self.friendArray[indexPath.row]["username"] as? String
            break
        case 1:
            cell.textLabel!.text = self.friendArray[indexPath.row]["username"] as? String
            break
        default :
            cell.textLabel!.text = self.friendArray[indexPath.row]["username"] as? String
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
    func loadData(){
        let usersData: PFQuery = PFQuery(className: "_User")
        usersData.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
        usersData.findObjectsInBackgroundWithBlock { objects, error in
            if error != nil {
                
            }else {
                for object in objects! {
                    self.friendArray.append(object)
                }
                self.friendTableView.reloadData()
            }
        }
    }
    
    func follow(indexPath: NSIndexPath) {
        let object = self.friendArray[indexPath.row] as! PFUser
        let currentUser = PFUser.currentUser()!
        currentUser.addUniqueObject(object.objectId!, forKey: "pending")
        currentUser.saveInBackgroundWithBlock { succeeded, error in
            if succeeded == true {
                AlertManager.showAlert(.Success, message: "友達申請しました")
                let push: PFPush = PFPush()
                push.setChannel(object.username)
                print(object.username)
                let message = String(format: "%@から友達リクエストが届きました", (PFUser.currentUser()?.username)!)
                push.setMessage(message)
                push.sendPushInBackground()
            }else {
                NSLog("エラー %@", error!.description)
                SVProgressHUD.showErrorWithStatus(error?.description)
            }
        }
    }
}
