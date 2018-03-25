//
//  AppDelegate.swift
//  botsocial
//
//  Created by Aamir  on 21/02/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack.init(modelName: "Pictogram")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        self.window = UIWindow.init()
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.white
        self.resetApp()
        if Auth.auth().currentUser == nil {
            BSCommons.showLoginPage(delegate: self)
        }
        
        return true
    }
    
    func getFeedPage() -> UIViewController {
        let vc = BSFeedViewController()
        vc.managedContext = coreDataStack.managedContext
        let navVC = UINavigationController.init(rootViewController: vc)
        return navVC
    }
    
    func getAccountPage() -> UIViewController {
        let navVC = UINavigationController.init(rootViewController: BSAccountViewController())
        navVC.isNavigationBarHidden = true
        return navVC
    }
    
    func getNotificationsPage() -> UIViewController {
        let navVC = UINavigationController.init(rootViewController: BSNotificationsViewController())
        return navVC
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        if let user = user {
            APIService.sharedInstance.updateUserDetails(user: user)
            do {
                let entityDesc = NSEntityDescription.entity(forEntityName: "UserObject", in: coreDataStack.managedContext)!
                let savedUser = UserObject.init(entity: entityDesc, insertInto: coreDataStack.managedContext)
                savedUser.id = user.uid
                savedUser.displayName = user.displayName
                try coreDataStack.managedContext.save()
                
            }
            catch let error as NSError {
                print("Error! \(error)")
            }
            
            
            self.resetApp()
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return BSLoginViewController.init(nibName: nil, bundle: nil, authUI: authUI)
    }

    func resetApp() {
        if let window = self.window {
            let rootVC = UITabBarController.init()
            let feedVC = getFeedPage()
            let accountVC = getAccountPage()
            let notifVC = getNotificationsPage()
            feedVC.tabBarItem.image = UIImage.init(named: "feed_tab_icon")
            notifVC.tabBarItem.image = UIImage.init(named: "notification_tab_icon")
            accountVC.tabBarItem.image = UIImage.init(named: "account_tab_icon")
            rootVC.viewControllers = [feedVC, notifVC, accountVC]
            rootVC.tabBar.tintColor = BSColorTextBlack
            window.rootViewController = rootVC
        }
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }

    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        coreDataStack.saveContext()
    }


}

