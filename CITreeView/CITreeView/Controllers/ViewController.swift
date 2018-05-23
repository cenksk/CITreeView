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
    //var treeView:CITreeView!
    
    let treeViewCellIdentifier = "TreeViewCellIdentifier"
    let treeViewCellNibName = "CITreeViewCell"

    @IBOutlet weak var sampleTreeView: CITreeView!
    override func viewDidLoad() {
        super.viewDidLoad()
        data = CITreeViewData.getDefaultCITreeViewData()
        sampleTreeView.collapseNoneSelectedRows = false
        sampleTreeView.register(UINib(nibName: treeViewCellNibName, bundle: nil), forCellReuseIdentifier: treeViewCellIdentifier)
    }
    
    @IBAction func reloadBarButtonAction(_ sender: UIBarButtonItem) {
        sampleTreeView.expandAllRows()
    }
    @IBAction func collapseAllRowsBarButtonAction(_ sender: UIBarButtonItem) {
        sampleTreeView.collapseAllRows()
        
    }
}

extension ViewController : CITreeViewDelegate {
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}
    
    func didExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}
    
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}
    
    func didCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {}
    
    
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> CGFloat {
        return 60
    }
    
    func treeView(_ treeView: CITreeView, didDeselectRowAt treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath) {
        
    }
    
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath) {
        if let parentNode = treeViewNode.parentNode{
            print(parentNode.item)
        }
    }
}

extension ViewController : CITreeViewDataSource {
    func treeViewSelectedNodeChildren(for treeViewNodeItem: AnyObject) -> [AnyObject] {
        if let dataObj = treeViewNodeItem as? CITreeViewData {
            return dataObj.children
        }
        return []
    }
    
    func treeViewDataArray() -> [AnyObject] {
        return data
    }
    
    func treeView(_ treeView: CITreeView, atIndexPath indexPath: IndexPath, withTreeViewNode treeViewNode: CITreeViewNode) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: treeViewCellIdentifier) as! CITreeViewCell
        let dataObj = treeViewNode.item as! CITreeViewData
        cell.nameLabel.text = dataObj.name
        cell.setupCell(level: treeViewNode.level)
        
        return cell;
    }

}



