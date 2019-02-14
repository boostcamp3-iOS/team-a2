//
//  AppDelegate.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // MARK: - Core Data stack
//    lazy var coreDataStack = CoreDataStack(modelName: "OneDay")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        guard let navController = window?.rootViewController as? UINavigationController,
//            let viewController = navController.topViewController as? SampleCoreDataViewController else {
//                return true
//        }
//        
//        viewController.managedObjectContext = coreDataStack.managedContext
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
//        window?.rootViewController = CollectedEntriesViewController()
        window?.rootViewController = CalendarViewController()

        //사용자 위치정보 권한 요청
        LocationService.service.requestAuth()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
