//
//  ReloadCollectionController.swift
//  SwiftCode
//
//  Created by 王金山 on 2022/4/18.
//

import UIKit

class ReloadCollectionController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collection)
        collection.mas_makeConstraints { make in
            make?.edges.equalTo()
        }
        collection.delegate = self
        collection.dataSource = self
        reload()
    }
    
    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.data = ["1", "2"]
//            self.tableview.reloadData()
//            self.data = ["1"]
            let index = IndexPath(row: 2, section: 2)
            if self.collection.indexPathIsValid(index) {
                self.collection.scrollToItem(at: index, at: .bottom, animated: true)
            } else {
                print("无效")
            }
            
            let nsindex = NSIndexPath(row: 2, section: 2)
            if self.collection.isValidIndex(index: nsindex) {
                self.collection.scrollToItem(at: nsindex as IndexPath, at: .bottom, animated: true)
            } else {
                print("无效2")
            }
        }
    }
    
    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        return layout
    }()

    lazy var collection: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
}

extension ReloadCollectionController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(red: CGFloat(indexPath.row) * 0.01, green: CGFloat(indexPath.row) * 0.02, blue: CGFloat(indexPath.row) * 0.03, alpha: 1)
        return cell
    }
}






