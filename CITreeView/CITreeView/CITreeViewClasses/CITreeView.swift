//
//  CITreeView.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

public protocol CITreeViewDataSource {
    func treeView(_ treeView:CITreeView, atIndexPath indexPath:IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> UITableViewCell
    func treeViewSelectedNodeChildren(for treeViewNodeItem:Any) -> [Any]
    func treeViewDataArray() -> [Any]
}

public protocol CITreeViewDelegate {
    
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> CGFloat
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode:CITreeViewNode)
    func willExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func didExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func willCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func didCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
}

public class CITreeView: UITableView {
    
    public var treeViewDataSource:CITreeViewDataSource?
    public var treeViewDelegate: CITreeViewDelegate?
    public var collapseNoneSelectedRows = false
    fileprivate var treeViewController = CITreeViewController(treeViewNodes: [])
    fileprivate var selectedTreeViewNode:CITreeViewNode?
    
    fileprivate var mainDataArray:[CITreeViewNode] = []
    
    
    override public init(frame: CGRect, style: UITableViewStyle) {
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
        treeViewController.treeViewControllerDelegate = self;
        self.backgroundColor = UIColor.clear
    }
    
    override public func reloadData() {
        
        guard let treeViewDataSource = self.treeViewDataSource else {
            mainDataArray = [CITreeViewNode]()
            return
        }
        
        if (treeViewDataSource.treeViewDataArray()).count > treeViewController.treeViewNodes.count {
            mainDataArray = [CITreeViewNode]()
            for item in treeViewDataSource.treeViewDataArray() {
                treeViewController.addTreeViewNode(with: item)
            }
            mainDataArray = treeViewController.treeViewNodes
        }
        super.reloadData()
    }
    
    public func expandAllRows() {
        treeViewController.expandAllRows()
        reloadData()
    }
    
    public func collapseAllRows() {
        treeViewController.collapseAllRows()
        reloadData()
    }
    
    fileprivate func deleteRows() {
        if treeViewController.indexPathsArray.count > 0 {
            self.beginUpdates()
            self.deleteRows(at: treeViewController.indexPathsArray, with: .automatic)
            self.endUpdates()
        }
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
                treeViewDelegate.didCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath:indexPath)
                completion()
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                treeViewDelegate.didCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
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
                treeViewDelegate.didExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
            })
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                treeViewDelegate.didExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
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
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        guard let treeViewDelegate = self.treeViewDelegate else { return 44 }
        return treeViewDelegate.treeView(tableView as! CITreeView,heightForRowAt: indexPath,withTreeViewNode :treeViewNode)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTreeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        guard let treeViewDelegate = self.treeViewDelegate else { return }
        
        if let justSelectedTreeViewNode = selectedTreeViewNode {
            treeViewDelegate.treeView(tableView as! CITreeView, didSelectRowAt: justSelectedTreeViewNode)
            var willExpandIndexPath = indexPath
            if justSelectedTreeViewNode.expand {
                treeViewController.collapseRows(for: justSelectedTreeViewNode, atIndexPath: indexPath)
                collapseRows(for: justSelectedTreeViewNode, atIndexPath: indexPath){}
            }
            else
            {
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
                    
                }else{
                    treeViewController.expandRows(atIndexPath: willExpandIndexPath, with: justSelectedTreeViewNode, openWithChildrens: false)
                    expandRows(for: justSelectedTreeViewNode, withSelected: indexPath)
                }
            }
        }
    }
}

extension CITreeView : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treeViewController.treeViewNodes.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let treeViewNode = treeViewController.getTreeViewNode(atIndex: indexPath.row)
        guard let treeViewDatasource = self.treeViewDataSource else { fatalError() }
        return treeViewDatasource.treeView(tableView as! CITreeView, atIndexPath: indexPath, withTreeViewNode: treeViewNode)
    }
}

extension CITreeView : CITreeViewControllerDelegate {
    public func getChildren(forTreeViewNodeItem item: Any, with indexPath: IndexPath) -> [Any] {
        guard let treeViewDatasource = self.treeViewDataSource else { return [] }
        return treeViewDatasource.treeViewSelectedNodeChildren(for: item)
    }
    
    public func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        guard let treeViewDelegate = self.treeViewDelegate else { return }
        treeViewDelegate.willCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
    
    public func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        guard let treeViewDelegate = self.treeViewDelegate else { return }
        treeViewDelegate.willExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
}

