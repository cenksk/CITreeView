//
//  ViewController.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var data : [CITreeViewData] = []
    var treeView:CITreeView!
    
    let treeViewCellIdentifier = "TreeViewCellIdentifier"
    let treeViewCellNibName = "CITreeViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        data = CITreeViewData.getDefaultCITreeViewData()
        treeView = CITreeView.init(frame: self.view.bounds, style: UITableViewStyle.plain)
        treeView.treeViewDelegate = self
        treeView.setDataSource(dataArray: data)
        treeView.collapseOtherNodesWhenSelectedOneOfTheOther = false
        treeView.register(UINib(nibName: treeViewCellNibName, bundle: nil), forCellReuseIdentifier: treeViewCellIdentifier)
        self.view.addSubview(treeView)
    }
}

extension ViewController:CITreeViewDelegate {
    
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
    
    func didExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
    
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
    
    func didCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
    }
    
    func treeView(_ treeView: CITreeView, atIndexPath indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: treeViewCellIdentifier) as! CITreeViewCell
        let dataObj = treeViewNode.item as! CITreeViewData
        cell.nameLabel.text = dataObj.name
        cell.setupCell(level: treeViewNode.level)
        
        return cell;
    }
    
    func treeViewItemForCell(withIndexPath indexPath: IndexPath) -> AnyObject {
        return data[indexPath.row]
    }
    
    
    func treeViewItemChild(andItem item: AnyObject) -> [AnyObject] {
        if let dataObj = item as? CITreeViewData {
            return dataObj.children
        }
        return []
    }
    
    func treeView(_ tableView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> CGFloat {
        return 60;
    }
    
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode:CITreeViewNode) {
    }
}


