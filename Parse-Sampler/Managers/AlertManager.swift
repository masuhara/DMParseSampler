//
//  AlertManager.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/10/04.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class AlertManager: NSObject {
    
    enum AlertType {
        case Normal, Success, Error
    }
    
    class func showAlert(alertType: AlertType, message: String) {
        switch alertType {
        case .Normal:
            //普通のアラート
            SVProgressHUD.showWithStatus(message)
            break
        case .Success:
            //成功したときのアラート
            SVProgressHUD.showSuccessWithStatus(message)
            break
        case .Error:
            //エラー時のアラート
            SVProgressHUD.showErrorWithStatus(message)
            break
        }
    }
    
    class func dismissAlert() {
        if SVProgressHUD.isVisible() == true {
            SVProgressHUD.dismiss()
        }
    }
}
