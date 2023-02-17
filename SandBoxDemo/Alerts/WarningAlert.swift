//
//  WarningAlert.swift
//  SandBoxDemo
//
//  Created by Aleksey Lexx on 15.02.2023.
//

import Foundation

import UIKit

class WarningAlert {
    
    static let defaultAlert = WarningAlert()
    
    func showAlert(showAlertIn viewController: UIViewController, message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "OK", style: .default) { alert in }
        alertController.addAction(alertOK)
        viewController.present(alertController, animated: true)
    }
}
