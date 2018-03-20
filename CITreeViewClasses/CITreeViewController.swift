//
//  CITreeViewController.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

public protocol CITreeViewControllerDelegate : NSObjectProtocol {
    func getChildren(forTreeViewNodeItem item:Any, with indexPath:IndexPath) -> [Any]
    func willExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func willCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
}

public class CITreeViewController:NSObject  {
    
    var treeViewNodes:[CITreeViewNode] = []
    var indexPathsArray:[IndexPath] = []
    weak var treeViewControllerDelegate:CITreeViewControllerDelegate?
    
    init(treeViewNodes : [CITreeViewNode]) {
        self.treeViewNodes = treeViewNodes
    }
    
    //MARK: Tree View Nodes Functions
    func addTreeViewNode(with item:Any){
        let treeViewNode = CITreeViewNode(item: item)
        let hasNodeBefore = treeViewNodes.filter{$0 == treeViewNode}
        
        if hasNodeBefore.count == 0 {
            treeViewNodes.append(treeViewNode)
        }
    }
    
    func getTreeViewNode(atIndex index: Int) -> CITreeViewNode
    {
        return treeViewNodes[index]
    }
    
    func insertTreeViewNode(with item:Any, to index : Int)
    {
        let treeViewNode = CITreeViewNode(item: item)
        treeViewNodes.insert(treeViewNode, at: index)
    }
    
    func removeTreeViewNodesAtRange(from start:Int , to end:Int)
    {
        treeViewNodes.removeSubrange(start ... end)
    }
    
    func setExpandTreeViewNode(atIndex index:Int){
        treeViewNodes[index].expand = true
    }
    
    func setCollapseTreeViewNode(atIndex index:Int){
        treeViewNodes[index].expand = false
    }
    
    func setLevelTreeViewNode(atIndex index:Int, to level:Int){
        treeViewNodes[index].level = level + 1
    }
    
    // MARK: Expand Rows
    
    func addIndexPath(withRow row:Int){
        let indexPath = IndexPath(row: row , section: 0)
        indexPathsArray.append(indexPath)
    }
    
    func expandRows(atIndexPath indexPath:IndexPath, with selectedTreeViewNode:CITreeViewNode){
        let children = self.treeViewControllerDelegate?.getChildren(forTreeViewNodeItem: selectedTreeViewNode.item, with: indexPath)
        indexPathsArray = [IndexPath]()
        var row = indexPath.row + 1
        
        if (children?.count)! > 0 {
            self.treeViewControllerDelegate?.willExpandTreeViewNode(treeViewNode: selectedTreeViewNode, atIndexPath: indexPath)
            setExpandTreeViewNode(atIndex: indexPath.row)
        }
        
        for item in children!{
            addIndexPath(withRow: row)
            insertTreeViewNode(with: item, to: row)
            setLevelTreeViewNode(atIndex: row, to: selectedTreeViewNode.level)
            row += 1
        }
    }
    
    // MARK: Collapse Rows
    func removeIndexPath(withRow row:inout Int, and indexPath:IndexPath){
        let treeViewNode = getTreeViewNode(atIndex: row)
        let children = self.treeViewControllerDelegate?.getChildren(forTreeViewNodeItem: treeViewNode.item, with: indexPath)
        
        let index = IndexPath(row: row , section: indexPath.section)
        indexPathsArray.append(index)
        row += 1
        
        if (treeViewNode.expand) {
            for _ in children!{
                removeIndexPath(withRow: &row, and: indexPath)
            }
        }
    }
    
    func collapseRows(for treeViewNode :CITreeViewNode, atIndexPath indexPath:IndexPath){
        let children = self.treeViewControllerDelegate?.getChildren(forTreeViewNodeItem: treeViewNode.item, with: indexPath)
        indexPathsArray = [IndexPath]()
        var row = indexPath.row + 1
        
        if (children?.count)! > 0 {
            self.treeViewControllerDelegate?.willCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: indexPath)
            setCollapseTreeViewNode(atIndex: indexPath.row)
        }
        
        for _ in children!{
            removeIndexPath(withRow: &row, and: indexPath)
        }
        removeTreeViewNodesAtRange(from: (indexPathsArray.first?.row)!, to: (indexPathsArray.last?.row)!)
    }
    
    func collapseAllRows() -> CITreeViewNode?{
        indexPathsArray = [IndexPath]()
        var collapsedTreeViewNode:CITreeViewNode? = nil
        var indexPath = IndexPath(row: 0, section: 0)
        for treeViewNode in treeViewNodes {
            if  treeViewNode.expand , treeViewNode.level == 0 {
                collapseRows(for: treeViewNode, atIndexPath: indexPath)
                collapsedTreeViewNode = treeViewNode
            }
            indexPath.row += 1
        }
        return collapsedTreeViewNode
    }
}
