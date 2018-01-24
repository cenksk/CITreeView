//
//  CITreeViewController.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

protocol CITreeViewControllerDelegate {
    func getChildrenForTreeViewNode(withIndexPath indexPath:IndexPath , andItem item:AnyObject) -> [AnyObject]
    func willExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func willCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
}

class CITreeViewController: NSObject {
    
    var treeViewNodes:[CITreeViewNode] = []
    var indexPathsArray:[IndexPath] = []
    var treeViewControllerDelegate:CITreeViewControllerDelegate?
    
    init(treeViewNodes : [CITreeViewNode]) {
        self.treeViewNodes = treeViewNodes
    }
    
    //MARK: Tree View Nodes Functions
    func getTreeViewNodeForItem(treeViewNodeItem item:AnyObject){
        let treeViewNode = CITreeViewNode(item: item)
        let hasNodeBefore = treeViewNodes.filter{$0 == treeViewNode}
        
        if hasNodeBefore.count == 0 {
            treeViewNodes.append(treeViewNode)
        }
    }
    
    func getTreeViewNodeFromArray(atIndex:Int)  -> CITreeViewNode
    {
        return treeViewNodes[atIndex]
    }
    
    func insertTreeViewNode(treeNodeItem item:AnyObject, index : Int)
    {
        let treeViewNode = CITreeViewNode(item: item)
        treeViewNodes.insert(treeViewNode, at: index)
    }
    
    func removeTreeNodeAtWithRange(startIndex:Int , endIndex:Int)
    {
        treeViewNodes.removeSubrange(startIndex ... endIndex)
    }
    
    func setExpandOrCollapseForTreeViewNode(atIndex:Int){
        treeViewNodes[atIndex].expand = !treeViewNodes[atIndex].expand
    }
    
    func setLevelForTreeViewNode(atIndex:Int, level:Int){
        treeViewNodes[atIndex].level = level + 1
    }
    
    // MARK: Expand Rows
    
    func addIndexPathToTreeView(willAddIndexPathRow:Int, willAddTreeNode:AnyObject, parentTreeViewNode:CITreeViewNode){
        let indexPath = IndexPath(row: willAddIndexPathRow , section: 0)
        indexPathsArray.append(indexPath)
        insertTreeViewNode(treeNodeItem: willAddTreeNode, index: willAddIndexPathRow)
        setLevelForTreeViewNode(atIndex: willAddIndexPathRow, level:parentTreeViewNode.level)
    }
    
    func expandRows(indexPath:IndexPath, selectedTreeViewNode:CITreeViewNode){
        let childrensOfSelectedTreeViewNode = self.treeViewControllerDelegate?.getChildrenForTreeViewNode(withIndexPath: indexPath, andItem: selectedTreeViewNode.item)
        indexPathsArray = [IndexPath]()
        var incrementIndexPath = indexPath.row + 1
        
        if (childrensOfSelectedTreeViewNode?.count)! > 0 {
            self.treeViewControllerDelegate?.willExpandTreeViewNode(treeViewNode: selectedTreeViewNode, atIndexPath: indexPath)
            setExpandOrCollapseForTreeViewNode(atIndex: indexPath.row)
        }
        
        for treeNode in childrensOfSelectedTreeViewNode!{
            addIndexPathToTreeView(willAddIndexPathRow: incrementIndexPath, willAddTreeNode: treeNode, parentTreeViewNode: selectedTreeViewNode)
            incrementIndexPath += 1
        }
    }
    
    // MARK: Collapse Rows
    func removeIndexPathFromTreeView( willAddIndexPathRow:inout Int, indexPath:IndexPath){
        let treeViewNode = getTreeViewNodeFromArray(atIndex: willAddIndexPathRow)
        let childrensOfDataItemArray = self.treeViewControllerDelegate?.getChildrenForTreeViewNode(withIndexPath: indexPath, andItem: treeViewNode.item)
        
        let index = IndexPath(row: willAddIndexPathRow , section: indexPath.section)
        indexPathsArray.append(index)
        willAddIndexPathRow += 1
        
        if (treeViewNode.expand) {
            for _ in childrensOfDataItemArray!{
                removeIndexPathFromTreeView(willAddIndexPathRow: &willAddIndexPathRow, indexPath: indexPath)
            }
        }
    }
    
    func collapseRows(indexPath:IndexPath, selectedTreeViewNode:CITreeViewNode){
        let childrensOfSelectedTreeViewNode = self.treeViewControllerDelegate?.getChildrenForTreeViewNode(withIndexPath: indexPath, andItem: selectedTreeViewNode.item)
        indexPathsArray = [IndexPath]()
        var incrementIndexPath = indexPath.row + 1
        
        if (childrensOfSelectedTreeViewNode?.count)! > 0 {
            self.treeViewControllerDelegate?.willCollapseTreeViewNode(treeViewNode: selectedTreeViewNode, atIndexPath: indexPath)
            setExpandOrCollapseForTreeViewNode(atIndex: indexPath.row)
        }
        
        for _ in childrensOfSelectedTreeViewNode!{
            removeIndexPathFromTreeView(willAddIndexPathRow: &incrementIndexPath,indexPath: indexPath)
        }
        
        removeTreeNodeAtWithRange(startIndex: (indexPathsArray.first?.row)!,endIndex: (indexPathsArray.last?.row)!)
    }
    
    func collapseAllRows(selectedTreeViewNode:CITreeViewNode) -> CITreeViewNode{
        indexPathsArray = [IndexPath]()
        var collapsedTreeViewNode = selectedTreeViewNode
        var indexPath = IndexPath(row: 0, section: 0)
        for treeViewNode in treeViewNodes {
            if  treeViewNode.expand , treeViewNode.level == 0, selectedTreeViewNode.level == 0 {
                collapseRows(indexPath: indexPath, selectedTreeViewNode: treeViewNode)
                collapsedTreeViewNode = treeViewNode
            }
            indexPath.row += 1
        }
        return collapsedTreeViewNode
    }
}
