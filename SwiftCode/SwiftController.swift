//
//  SwiftController.swift
//  OCMasoryDemo
//
//  Created by 王金山 on 2022/3/3.
//

import UIKit

class SwiftController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        setupUI()
    }
}

extension SwiftController {
    func setupUI() {
        let button = UIButton()
        view.addSubview(button)
        button.backgroundColor = .yellow
        button.mas_makeConstraints { make in
            make?.left.equalTo()(20)
            make?.top.equalTo()(100)
            make?.width.equalTo()(100)
            make?.height.equalTo()(100)
        }
        
        let button2 = UIButton()
        button2.backgroundColor = .blue
        view.addSubview(button2)
        button2.mas_makeConstraints { make in
            make?.left.mas_equalTo()(button.mas_right)?.equalTo()(20)
            make?.top.height().mas_equalTo()(button)
            make?.right.mas_equalTo()(button)?.multipliedBy()(2)
        }
        
        let button3 = UIButton()
        button3.backgroundColor = .brown
        view.addSubview(button3)
        button3.mas_makeConstraints { make in
            make?.left.equalTo()(button)
            make?.top.equalTo()(button.mas_bottom)?.setOffset(20)
            make?.width.height().equalTo()(button)
        }
    }
}
