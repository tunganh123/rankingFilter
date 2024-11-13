//
//  UIViewController+Extensions.swift
//  AppLock
//
//  Created by Tung Anh on 05/10/2023.
//
import UIKit

public extension UIViewController { 
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - 64, y: self.view.frame.height - 200, width: 128, height: 43))
        toastLabel.backgroundColor = UIColor(hex: "#00CD46")
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 43 / 2
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)

        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }

    func showConfirmDelete(message: String, title: String = "Confirm Delete All Data?", okHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Thêm nút "Cancel"
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Thêm nút "OK" và gọi closure khi nhấn
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            okHandler()
        }))

        // Hiển thị alert
        present(alert, animated: true, completion: nil)
    }

    func showAlertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func presentAlertVC(_ alertVC: UIAlertController) {
        if isIPad,
           let popoverController = alertVC.popoverPresentationController
        {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                  y: self.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }

        if let presentedViewController = presentedViewController {
            if !presentedViewController.isKind(of: UIAlertController.self) {
                presentedViewController.present(alertVC, animated: true, completion: nil)
            }
        } else {
            present(alertVC, animated: true, completion: nil)
        }
    }
}
