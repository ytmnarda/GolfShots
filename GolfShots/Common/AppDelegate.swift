//
//  AppDelegate.swift
//  GolfShots
//
//  Created by Arda Yatman on 9.02.2022.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        configureRealm()
        setNavigationBar()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        
        return true
        
    }
    
    func setNavigationBar() {
        
        let appearance = UINavigationBarAppearance()
        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 23)!]
        appearance.titleTextAttributes = attributes
        
        if #available(iOS 15, *) {
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    func configureRealm() {
        
     //   print(Realm.Configuration.defaultConfiguration.fileURL)

        do {
             _ = try Realm()
        }catch {
            print(error)
        }
        
        //DELETE ALL DATA
       // try! FileManager.default.removeItem(at:Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
}

