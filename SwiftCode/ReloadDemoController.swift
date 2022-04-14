//
//  ReloadDemoController.swift
//  SwiftCode
//
//  Created by 王金山 on 2022/4/14.
//

import UIKit

class ReloadDemoController: UIViewController {

    var data: [String] = []
    
    let tableview = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
        
        view.addSubview(tableview)
        tableview.mas_makeConstraints { make in
            make?.edges.equalTo()
        }
        reload()
    }
    
    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.data = ["1", "2"]
            self.tableview.reloadData()
            self.data = ["1"]
        }
    }
}

extension ReloadDemoController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(data.count)
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}

