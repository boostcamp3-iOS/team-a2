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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //사용자 위치정보 권한 요청
        LocationService.service.requestAuth()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.save()
    }
}
