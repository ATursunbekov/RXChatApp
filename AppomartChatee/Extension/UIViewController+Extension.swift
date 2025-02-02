//
//  UIViewController+Extension.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 30/1/25.
//

import UIKit

extension UIViewController {
    func showErrorAlert(title: String = "Error", message: String, buttonTitle: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
