//
//  SceneDelegate.swift
//  SandBoxDemo
//
//  Created by Aleksey Lexx on 06.11.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
        //print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        self.window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        window?.rootViewController = openLoginViewController()
        window?.makeKeyAndVisible()
    }
    
    //метод определяет состояние кнопки ввода пароля
    func openLoginViewController() -> UIViewController {
        let loginInspector = LoginInspector.shared.keychain.allKeys()
        var loginVC = LoginViewController(authMode: .signUp)
        if loginInspector.isEmpty {
            loginVC = LoginViewController(authMode: .signUp)
        } else {
            loginVC = LoginViewController(authMode: .logIn)
        }
        return loginVC
    }
    
    struct TabBarModel {
        let title: String
        let image: UIImage?
        let tag: Int
    }
}

