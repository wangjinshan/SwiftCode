//
//  CodeViewController.swift
//  OCMasoryDemo
//
//  Created by 王金山 on 2022/3/3.
//

import UIKit

class CodeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


extension CodeViewController {
    func demo() {
        UserDefaultsConfig.hadShownGuideView = false
        print(UserDefaultsConfig.hadShownGuideView) // false
        UserDefaultsConfig.hadShownGuideView = true
        print(UserDefaultsConfig.hadShownGuideView) // true
    }
}
