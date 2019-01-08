//
//  CITreeViewController.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

@objc
public protocol CITreeViewDataSource: NSObjectProtocol {
    func treeView(_ treeView: CITreeView, cellForRowAt indexPath: IndexPath, with treeViewNode: CITreeViewNode) -> UITableViewCell
    func treeViewSelectedNodeChildren(for treeViewNodeItem: Any) -> [Any]
    func treeViewDataArray() -> [Any]
}

@objc
public protocol CITreeViewDelegate: NSObjectProtocol {
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, with treeViewNode: CITreeViewNode) -> CGFloat
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode: CITreeViewNode, at indexPath: IndexPath)
    func treeView(_ treeView: CITreeView, didDeselectRowAt treeViewNode: CITreeViewNode, at indexPath: IndexPath)
    func treeViewNode(_ treeViewNode: CITreeViewNode, willExpandAt indexPath: IndexPath)
    func treeViewNode(_ treeViewNode: CITreeViewNode, didExpandAt indexPath: IndexPath)
    func treeViewNode(_ treeViewNode: CITreeViewNode, willCollapseAt indexPath: IndexPath)
    func treeViewNode(_ treeViewNode: CITreeViewNode, didCollapseAt indexPath: IndexPath)
    
}

public class CITreeView: UITableView {
    
    @IBOutlet open weak var treeViewDataSource:CITreeViewDataSource?
    @IBOutlet open weak var treeViewDelegate: CITreeViewDelegate?
    fileprivate var treeViewController = CITreeViewController(treeViewNodes: [])
    fileprivate var selectedTreeViewNode:CITreeViewNode?
    public var collapseNoneSelectedRows = false
    fileprivate var mainDataArray:[CITreeViewNode] = []
    
    
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        super.delegate = self
        super.dataSource = self
        treeViewController.treeViewControllerDelegate = self as CITreeViewControllerDelegate
        self.backgroundColor = UIColor.clear
    }
    
    override public func reloadData() {
        
        guard let treeViewDataSource = self.treeViewDataSource else {
            mainDataArray = [CITreeViewNode]()
            return
        }
        
        mainDataArray = [CITreeViewNode]()
        treeViewController.treeViewNodes.removeAll()
        for item in treeViewDataSource.treeViewDataArray() {
            treeViewController.addTreeViewNode(with: item)
        }
        mainDataArray = treeViewController.treeViewNodes
        
        super.reloadData()
    }

    public func reloadDataWithoutChangingRowStates() {
        
        guard let treeViewDataSource = self.treeViewDataSource else {
            mainDataArray = [CITreeViewNode]()
            return
        }
        
        if treeViewDataSource.treeViewDataArray().count > treeViewController.treeViewNodes.count {
            mainDataArray = [CITreeViewNode]()
            treeViewController.treeViewNodes.removeAll()
            for item in treeViewDataSource.treeViewDataArray() {
                treeViewController.addTreeViewNode(with: item)
            }
            mainDataArray = treeViewController.treeViewNodes
        }
        super.reloadData()
    }
    
    fileprivate func deleteRows() {
        if treeViewController.indexPathsArray.count > 0 {
            self.beginUpdates()
            self.deleteRows(at: treeViewController.indexPathsArray, with: .automatic)
            self.endUpdates()
        }
    }
    
    public func deleteRow(at indexPath:IndexPath) {
        self.beginUpdates()
        self.deleteRows(at: [indexPath], with: .automatic)
        self.endUpdates()
    }
    
    fileprivate func insertRows() {
        if treeViewController.indexPathsArray.count > 0 {
            self.beginUpdates()
            self.insertRows(at: treeViewController.indexPathsArray, with: .automatic)
            self.endUpdates()
        }
    }
    
    fileprivate func collapseRows(for treeViewNode: CITreeViewNode, atIndexPath indexPath: IndexPath ,completion: @escaping () -> Void) {
        guard let treeViewDelegate = self.treeViewDelegate else { return }
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                deleteRows()
            }, completion: { (complete) in
                treeViewDelegate.treeViewNode(treeViewNode, didCollapseAt: indexPath)
                completion()
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                treeViewDelegate.treeViewNode(treeViewNode, didCollapseAt: indexPath)
                completion()
            })
            deleteRows()
            CATransaction.commit()
        }
    }
    
    fileprivate func expandRows(for treeViewNode: CITreeViewNode, withSelected indexPath: IndexPath) {
        guard let treeViewDelegate = self.treeViewDelegate else {return}
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                insertRows()
            }, completion: { (complete) in
                treeViewDelegate.treeViewNode(treeViewNode, didExpandAt: indexPath)
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                treeViewDelegate.treeViewNode(treeViewNode, didExpandAt: indexPath)
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
    
    public func expandAllRows() {
        treeViewController.expandAllRows()
        reloadDataWithoutChangingRowStates()
    }
    
    public func collapseAllRows() {
        treeViewController.collapseAllRows()
        reloadDataWithoutChangingRowStates()
    }
}

extension CITreeView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        return (self.treeViewDelegate?.treeView(tableView as! CITreeView, heightForRowAt: indexPath, with: treeViewNode))!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTreeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        guard let treeViewDelegate = self.treeViewDelegate else { return }
        
        if let justSelectedTreeViewNode = selectedTreeViewNode {
            treeViewDelegate.treeView(tableView as! CITreeView, didSelectRowAt: justSelectedTreeViewNode, at: indexPath)
            var willExpandIndexPath = indexPath
            if justSelectedTreeViewNode.expand {
                treeViewController.collapseRows(for: justSelectedTreeViewNode, atIndexPath: indexPath)
                collapseRows(for: justSelectedTreeViewNode, atIndexPath: indexPath){}
            } else {
                if collapseNoneSelectedRows,
                    selectedTreeViewNode?.level == 0,
                    let collapsedTreeViewNode = treeViewController.collapseAllRowsExceptOne(),
                    treeViewController.indexPathsArray.count > 0 {
                    
                    collapseRows(for: collapsedTreeViewNode, atIndexPath: indexPath){
                        for (index, treeViewNode) in self.mainDataArray.enumerated() {
                            if treeViewNode == justSelectedTreeViewNode {
                                willExpandIndexPath.row = index
                            }
                        }
                        self.treeViewController.expandRows(atIndexPath: willExpandIndexPath, with: justSelectedTreeViewNode, openWithChildrens: false)
                        self.expandRows(for: justSelectedTreeViewNode, withSelected: indexPath)
                    }
                } else {
                    treeViewController.expandRows(atIndexPath: willExpandIndexPath, with: justSelectedTreeViewNode, openWithChildrens: false)
                    expandRows(for: justSelectedTreeViewNode, withSelected: indexPath)
                }
            }
        }
    }
}

extension CITreeView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treeViewController.treeViewNodes.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        return (self.treeViewDataSource?.treeView(tableView as! CITreeView, cellForRowAt: indexPath, with: treeViewNode))!
    }
}

extension CITreeView: CITreeViewControllerDelegate {
    public func getChildren(for treeViewNodeItem: Any, at indexPath: IndexPath) -> [Any] {
        return (self.treeViewDataSource?.treeViewSelectedNodeChildren(for: treeViewNodeItem)) ?? []
    }
    
    public func willCollapseTreeViewNode(_ treeViewNode: CITreeViewNode, at indexPath: IndexPath) {
        self.treeViewDelegate?.treeViewNode(treeViewNode, willCollapseAt: indexPath)
    }
    
    public func willExpandTreeViewNode(_ treeViewNode: CITreeViewNode, at indexPath: IndexPath) {
        self.treeViewDelegate?.treeViewNode(treeViewNode, willExpandAt: indexPath)
    }
}
