//
//  SceneDelegate.swift
//  chatUI
//
//  Created by Faris Albalawi on 4/17/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let view = MessagesView()
        window.rootViewController = UINavigationController(rootViewController: view)
        self.window = window
        window.makeKeyAndVisible()
        
    }

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Send a message that informs all listening classes for becoming active again
        NotificationCenter.default.post(name: Notification.Name("appBecomesActive"), object: nil)

    }

    func sceneWillResignActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name("appResignActive"), object: nil)

    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: Notification.Name("appEntersBackground"), object: nil)

    }


}

