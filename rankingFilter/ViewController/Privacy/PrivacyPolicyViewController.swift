//
//  PrivacyPolicyViewController.swift
//  HeartRate
//
//  Created by Huy Toàn on 10/11/2023.
//

import UIKit

class PrivacyPolicyViewController: BaseViewController {
    static var shared = PrivacyPolicyViewController()
    @IBOutlet var textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavi(title: "Privacy Policy", imageLeft: "ic_back")
    }

    override func actionLeftItem() {
        
        navigationController?.popViewController(animated: true)
    }
}
