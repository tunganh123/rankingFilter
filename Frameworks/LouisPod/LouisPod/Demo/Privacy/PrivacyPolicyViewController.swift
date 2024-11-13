//
//  PrivacyPolicyViewController.swift
//  HeartRate
//
//  Created by Huy Toàn on 10/11/2023.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    static var shared = PrivacyPolicyViewController()
    @IBOutlet var textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarbutton()
        navigationItem.title = "Privacy Policy"
    }

    func setupBarbutton() {
        let Barbuttonback = setupBarbuttonright(nameimg: "ic_Back", wi: 25, he: 25, target: self, action: #selector(back))
        navigationItem.leftBarButtonItems = [Barbuttonback]
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}
