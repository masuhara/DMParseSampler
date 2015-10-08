//
//  Message.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/10/01.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var roomID: String!
    var messageArray = [NSDictionary]()
    
    class var sharedInstance: Message {
        // Singleton
        struct Static{
            static let instance: Message = Message()
        }
        return Static.instance
    }
    
    override private init() {
        super.init()
        self.roomID = ""
        self.messageArray = [NSDictionary]()
    }
}
