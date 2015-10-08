//
//  ChatViewController.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/09/30.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate {
    
    var objectArray = [PFObject]()
    @IBOutlet var chatTableView: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    var refreshControl: UIRefreshControl!
    var selectedIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.chatTableView.dataSource = self
        self.chatTableView.delegate = self
        self.chatTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.embedPullToRefresh()
        
        self.read()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as UITableViewCell!
        if self.objectArray.count > 0 {
            cell.textLabel!.text = self.objectArray[indexPath.row]["text"] as? String
        }
        self.selectedIndexPath = indexPath
        return cell
    }
    
    // MARK: Private
    @IBAction private func create() {
        self.showInputAlert("テキストを入力", mainButtonTitle: "保存", cancelButtonTitle: "キャンセル")
    }
    
    func read() {
        self.addButton.enabled = false
        self.objectArray = [PFObject]()
        let query: PFQuery = PFQuery(className: "Basic")
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { objects, error in
            if(error == nil){
                self.objectArray = objects!
            }else {
                AlertManager.showAlert(.Error, message: "読み込みに失敗しました")
            }
            
            self.refreshControl.endRefreshing()
            self.addButton.enabled = true
            AlertManager.dismissAlert()
            self.chatTableView.reloadData()
        }
    }
    
    private func showInputAlert(title: String, mainButtonTitle: String, cancelButtonTitle: String) {
        let alert = UIAlertView()
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.title = title
        alert.textFieldAtIndex(0)!.placeholder = "ここに文字を入力"
        alert.addButtonWithTitle(mainButtonTitle)
        alert.addButtonWithTitle(cancelButtonTitle)
        alert.delegate = self
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        alertView.dismissWithClickedButtonIndex(buttonIndex, animated: false)
        if buttonIndex == 0 {
            if alertView.textFieldAtIndex(0)!.text == nil {
                AlertManager.showAlert(.Error, message: "文字を入力して下さい")
            }else {
                self.save(alertView)
            }
        }else {
            // cancel
        }
    }
    
    private func save(alertView: UIAlertView) {
        // create
        let object = PFObject(className: "Basic")
        object["text"] = alertView.textFieldAtIndex(0)!.text
        object.saveInBackgroundWithBlock { success, error in
            if success {
                self.read()
            }else {
                AlertManager.showAlert(.Error, message: "保存失敗")
            }
        }
    }
    
    private func embedPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("read"), forControlEvents: UIControlEvents.ValueChanged)
        self.chatTableView.addSubview(self.refreshControl)
    }
}
