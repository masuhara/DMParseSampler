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
            SVProgressHUD.showWithStatus(message)
            break
        case .Success:
            SVProgressHUD.showSuccessWithStatus(message)
            break
        case .Error:
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
