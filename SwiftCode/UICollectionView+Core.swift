//
//  UICollectionView+Core.swift
//  SwiftCode
//
//  Created by 王金山 on 2022/4/18.
//

import UIKit

public extension UICollectionView {
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = self.numberOfSections - 1
        if indexPath.section > section {
            return false
        }
        let row = self.numberOfItems(inSection: indexPath.section) - 1
        return indexPath.row <= row
    }
}

public extension UITableView {
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = self.numberOfSections - 1
        if indexPath.section > section {
            return false
        }
        let row = self.numberOfRows(inSection: indexPath.section) - 1
        return indexPath.row <= row
    }
}

// 验证
public extension UICollectionView {
    func isValidIndex(index: NSIndexPath) -> Bool {
        if index.section < numberOfSections {
            return index.row < numberOfItems(inSection: index.section)
        }
        return false
    }
}

public extension UITableView {
//    func isValidIndex(index: NSIndexPath) -> Bool {
//        if index.section < numberOfSections {
//            return index.row < numberOfItems(inSection: index.section)
//        }
//        return false
//    }
}
