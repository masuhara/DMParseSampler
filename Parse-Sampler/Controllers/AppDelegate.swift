//
//  AppDelegate.swift
//  Parse-Sampler
//
//  Created by Masuhara on 2015/09/30.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ParseManager.setID("HH18BAqPPKUInLfVcfBY7wi4ZQV6ocQ2Y9wMul0X", withKey: "4Oc4ifwGm6qtClC4NgNGCFO7FQYBwerZpnRpKWMB")
        
        PFUser.currentUser()
        let defaultACL = PFACL()
        defaultACL.setPublicReadAccess(true)
        defaultACL.setPublicWriteAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
        
        if application.applicationState != UIApplicationState.Background {
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                //PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
                PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }else {
            print("else")
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Push Notifications
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock { succeeded, error in
            if error != nil {
                // TODO: GoogleAnalytics
                print("parsePushUserAssign save error.")
            }else {
                PFPush.subscribeToChannelInBackground("all" , block: { succeeded, error in
                    if succeeded {
                        // TODO: GoogleAnalytics
                        print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
                    }else {
                        // TODO: GoogleAnalytics
                        print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
                    }
                })
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
}

