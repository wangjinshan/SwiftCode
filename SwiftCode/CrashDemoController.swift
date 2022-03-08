//
//  CrashDemoController.swift
//  SwiftCode
//
//  Created by 王金山 on 2022/3/7.
//

import UIKit
import Masonry

class CrashDemoController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableview = UITableView()
        view.addSubview(tableview)
        tableview.mas_makeConstraints { make in
            make?.edges.equalTo()(view)
        }
        tableview.delegate = self
        tableview.dataSource = self
    }
}

extension CrashDemoController: UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

