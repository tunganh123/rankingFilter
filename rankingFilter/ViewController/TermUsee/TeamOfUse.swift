//
//  TeamOfUse.swift
//  HeadUptest
//
//  Created by TungAnh on 22/5/24.
//

import UIKit

class TeamOfUse: BaseViewController {
    static var shared = TeamOfUse()

    @IBOutlet var tv: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi(title: "Terms of Service", imageLeft: "ic_back")
        view.backgroundColor = .white
        tv.backgroundColor = .white
        if UIDevice.current.userInterfaceIdiom == .pad {
            tv.font = UIFont(name: "Poppins-Regular", size: 20)
        } else {
            tv.font = UIFont(name: "Poppins-Regular", size: 17)
        }
    }

    override func actionLeftItem() {
        
        navigationController?.popViewController(animated: true)
    }
}
