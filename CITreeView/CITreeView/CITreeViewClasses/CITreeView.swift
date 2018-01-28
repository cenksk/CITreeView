//
//  CITreeView.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

protocol CITreeViewDataSource {
    func treeView(_ treeView:CITreeView, atIndexPath indexPath:IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> UITableViewCell
    func treeViewSelectedNodeChildren(for treeViewNodeItem:AnyObject) -> [AnyObject]
    func treeViewDataArray() -> [AnyObject]
}

protocol CITreeViewDelegate {
    
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> CGFloat
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode:CITreeViewNode)
    func willExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func didExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func willCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func didCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
}

class CITreeView: UITableView {
    
    var treeViewDataSource:CITreeViewDataSource?
    var treeViewDelegate: CITreeViewDelegate?
    fileprivate var treeViewController = CITreeViewController(treeViewNodes: [])
    fileprivate var selectedTreeViewNode:CITreeViewNode?
    var collapseNoneSelectedRows = false
    fileprivate var mainDataArray:[CITreeViewNode] = []
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        super.delegate = self
        super.dataSource = self
        treeViewController.treeViewControllerDelegate = self as CITreeViewControllerDelegate;
        self.backgroundColor = UIColor.clear
    }
    
    override func reloadData() {
        treeViewController.treeViewNodes = [CITreeViewNode]()
        super.reloadData()
    }
    
    fileprivate func deleteRows() {
        self.beginUpdates()
        self.deleteRows(at: treeViewController.indexPathsArray, with: .automatic)
        self.endUpdates()
    }
    
    fileprivate func insertRows() {
        self.beginUpdates()
        self.insertRows(at: treeViewController.indexPathsArray, with: .automatic)
        self.endUpdates()
    }
    
    fileprivate func collapseRows(for treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath) {
        
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                deleteRows()
            }, completion: { (complete) in
                self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath:indexPath)
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
            })
            deleteRows()
            CATransaction.commit()
        }
    }
    
    fileprivate func expandRows(for treeViewNode: CITreeViewNode, withSelected indexPath: IndexPath) {
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                insertRows()
            }, completion: { (complete) in
                self.treeViewDelegate?.didExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.treeViewDelegate?.didExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
            })
            insertRows()
            CATransaction.commit()
        }
    }
    
    func getAllCells() -> [UITableViewCell] {
        var cells = [UITableViewCell]()
        for section in 0 ..< self.numberOfSections{
            for row in 0 ..< self.numberOfRows(inSection: section){
                cells.append(self.cellForRow(at: IndexPath(row: row, section: section))!)
            }
        }
        return cells
    }
}

extension CITreeView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        return (self.treeViewDelegate?.treeView(tableView as! CITreeView,heightForRowAt: indexPath,withTreeViewNode :treeViewNode))!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTreeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        self.treeViewDelegate?.treeView(tableView as! CITreeView, didSelectRowAt: selectedTreeViewNode!)
        var willExpandIndexPath = indexPath
        if (selectedTreeViewNode?.expand)! {
            treeViewController.collapseRows(for: selectedTreeViewNode!, atIndexPath: indexPath)
            collapseRows(for: self.selectedTreeViewNode!, atIndexPath: indexPath)
        }
        else
        {
            if collapseNoneSelectedRows, selectedTreeViewNode?.level == 0 {
                if let collapsedTreeViewNode = treeViewController.collapseAllRows() {
                    if treeViewController.indexPathsArray.count > 0 {
                        collapseRows(for: collapsedTreeViewNode, atIndexPath: indexPath)
                        for (index, treeViewNode) in mainDataArray.enumerated() {
                            if treeViewNode == selectedTreeViewNode {
                                willExpandIndexPath.row = index
                            }
                        }
                    }
                }
            }
            treeViewController.expandRows(atIndexPath: willExpandIndexPath, with: selectedTreeViewNode!)
            
            expandRows(for: self.selectedTreeViewNode!, withSelected: indexPath)
        }
    }
}

extension CITreeView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.treeViewDataSource?.treeViewDataArray())!.count > treeViewController.treeViewNodes.count {
            mainDataArray = [CITreeViewNode]()
            for item in (self.treeViewDataSource?.treeViewDataArray())! {
                treeViewController.addTreeViewNode(with: item)
            }
            mainDataArray = treeViewController.treeViewNodes
        }
        return treeViewController.treeViewNodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        return (self.treeViewDataSource?.treeView(tableView as! CITreeView, atIndexPath: indexPath, withTreeViewNode: treeViewNode))!
    }
}

extension CITreeView : CITreeViewControllerDelegate {
    func getChildren(forTreeViewNodeItem item: AnyObject, with indexPath: IndexPath) -> [AnyObject] {
        return (self.treeViewDataSource?.treeViewSelectedNodeChildren(for: item))!
    }
    
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        self.treeViewDelegate?.willCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
    
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        self.treeViewDelegate?.willExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
}

