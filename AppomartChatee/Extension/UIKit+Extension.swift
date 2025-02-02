//
//  UIKit+Extension.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 1/2/25.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(context _: Context) -> some UIViewController {
            viewController
        }

        func updateUIViewController(_: UIViewControllerType, context _: Context) {
//            if let colorChangeVC = uiViewController as? ColorChangeViewController {
//                colorChangeVC.toggleColor()
//            }
        }
    }

    func showPreview() -> some View {
        Preview(viewController: self).edgesIgnoringSafeArea(.all)
    }
}
