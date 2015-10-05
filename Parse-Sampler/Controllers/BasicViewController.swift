//
//  BasicViewController.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/09/30.
//  Copyright © 2015年 masuhara. All rights reserved.
//
/* ========= BasicViewController =========== */
/* BasicViewControllerでは、データベースの基本であるCRUDの基礎を学びます。
CRUD(クラッド)とは、C(Create)、R(Read)、U(Update)、D(Delete)の4つの機能を言います。
*/

import UIKit

class BasicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate {
    
    var objectArray = [PFObject]()
    @IBOutlet var basicTableView: UITableView!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    var refreshControl: UIRefreshControl!
    var selectedIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.basicTableView.dataSource = self
        self.basicTableView.delegate = self
        self.embedPullToRefresh()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
        if self.objectArray.count > 0 {
            cell.textLabel!.text = self.objectArray[indexPath.row]["text"] as? String
        }
        self.selectedIndexPath = indexPath
        return cell
    }
    
    // MARK: TableViewDelegate
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.selectedIndexPath = indexPath
            self.delete()
            self.objectArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        self.showInputAlert("編集モード", mainButtonTitle: "保存", cancelButtonTitle: "キャンセル")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Private
    @IBAction private func create() {
        self.showInputAlert("テキストを入力", mainButtonTitle: "保存", cancelButtonTitle: "キャンセル")
    }
    
    @IBAction private func read() {
        self.refreshButton.enabled = false
        self.addButton.enabled = false
        if self.refreshControl.refreshing == false {
            AlertManager.showAlert(.Normal, message: "読み込み中...")
        }
        self.objectArray = [PFObject]()
        let query: PFQuery = PFQuery(className: "Basic")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { objects, error in
            if(error == nil){
                self.objectArray = objects!
            }else {
                AlertManager.showAlert(.Error, message: "読み込みに失敗しました")
            }
            self.refreshControl.endRefreshing()
            self.refreshButton.enabled = true
            self.addButton.enabled = true
            AlertManager.dismissAlert()
            self.basicTableView.reloadData()
        }
    }
    
    private func update(alertView: UIAlertView) {
        // update
        let query = PFQuery(className: "Basic")
        query.getObjectInBackgroundWithId(objectArray[self.selectedIndexPath.row].objectId!) { object, error in
            if error == nil {
                object!["text"] = alertView.textFieldAtIndex(0)!.text
                object!.saveInBackgroundWithBlock { success, error in
                    if success {
                        AlertManager.showAlert(.Success, message: "保存成功")
                    }else {
                        AlertManager.showAlert(.Error, message: "保存失敗")
                    }
                }
            }else {
               print(error)
            }
        }
    }
    
    private func delete() {
        let query: PFQuery = PFQuery(className: "Basic")
        query.orderByDescending("createdAt")
        print(self.selectedIndexPath)
        query.getObjectInBackgroundWithId(objectArray[self.selectedIndexPath.row].objectId!) { object, error in
            if error == nil {
                object!.deleteInBackgroundWithBlock { success, error in
                    if error == nil {
                        AlertManager.showAlert(.Success, message: "削除しました")
                    }else {
                        AlertManager.showAlert(.Error, message: "削除に失敗しました")
                    }
                }
            }else {
                AlertManager.showAlert(.Error, message: "削除に失敗しました")
            }
        }
    }
    
    private func showInputAlert(title: String, mainButtonTitle: String, cancelButtonTitle: String) {
        let alert = UIAlertView()
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.title = title
        if alert.title == "編集モード" {
            alert.tag = 1
            alert.textFieldAtIndex(0)!.text = self.objectArray[selectedIndexPath.row]["text"] as? String
        }else {
            alert.tag = 0
        }
        alert.textFieldAtIndex(0)!.placeholder = "ここに文字を入力"
        alert.addButtonWithTitle(mainButtonTitle)
        alert.addButtonWithTitle(cancelButtonTitle)
        alert.delegate = self
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        alertView.dismissWithClickedButtonIndex(buttonIndex, animated: false)
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.tag == 1 {
            if buttonIndex == 0 {
                // update
                self.update(alertView)
            }else {
                // cancel
            }
        }else {
            if buttonIndex == 0 {
                // save
                self.save(alertView)
            }else {
                // cancel
            }
        }
    }
    
    private func save(alertView: UIAlertView) {
        AlertManager.showAlert(.Normal, message: "保存中...")
        if alertView.tag == 0 {
            // create
            let object = PFObject(className: "Basic")
            object["text"] = alertView.textFieldAtIndex(0)!.text
            object.saveInBackgroundWithBlock { success, error in
                if success {
                    AlertManager.showAlert(.Success, message: "保存成功")
                }else {
                    AlertManager.showAlert(.Error, message: "保存失敗")
                }
            }
        }
    }
    
    private func embedPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: Selector("read"), forControlEvents: UIControlEvents.ValueChanged)
        self.basicTableView.addSubview(self.refreshControl)
    }
}
