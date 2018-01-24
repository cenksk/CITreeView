//
//  CITreeView.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

protocol CITreeViewDelegate {
    func treeView(_ treeView:CITreeView, atIndexPath indexPath:IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> UITableViewCell
    func treeView(_ treeView: CITreeView, heightForRowAt indexPath: IndexPath, withTreeViewNode treeViewNode:CITreeViewNode) -> CGFloat
    func treeView(_ treeView: CITreeView, didSelectRowAt treeViewNode:CITreeViewNode)
    func treeViewItemChild( andItem item:AnyObject) -> [AnyObject]
    func willExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func didExpandTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func willCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
    func didCollapseTreeViewNode(treeViewNode:CITreeViewNode, atIndexPath: IndexPath)
}

class CITreeView: UITableView {
    
    var treeViewDelegate:CITreeViewDelegate?
    var treeViewController: CITreeViewController?
    var selectedTreeViewNode:CITreeViewNode?
    var collapseOtherNodesWhenSelectedOneOfTheOther:Bool = false
    var mainDataArray:[CITreeViewNode] = []
    
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
        self.treeViewController = CITreeViewController(treeViewNodes: [])
        self.treeViewController?.treeViewControllerDelegate = self
        self.backgroundColor = UIColor.clear
    }
    
    func setDataSource(dataArray:[AnyObject]){
        mainDataArray = [CITreeViewNode]()
        treeViewController?.treeViewNodes = [CITreeViewNode]()
        for dataItem in dataArray {
            treeViewController?.getTreeViewNodeForItem(treeViewNodeItem: dataItem)
        }
        mainDataArray = (treeViewController?.treeViewNodes)!
    }
}

extension CITreeView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let treeViewNode = self.treeViewController?.getTreeViewNodeFromArray(atIndex: indexPath.row)
        return (self.treeViewDelegate?.treeView(tableView as! CITreeView,heightForRowAt: indexPath,withTreeViewNode :treeViewNode!))!
    }
}

extension CITreeView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.treeViewController?.treeViewNodes.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let treeViewNode = self.treeViewController?.getTreeViewNodeFromArray(atIndex: indexPath.row)
        return (self.treeViewDelegate?.treeView(tableView as! CITreeView, atIndexPath: indexPath, withTreeViewNode: treeViewNode!))!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTreeViewNode = self.treeViewController?.getTreeViewNodeFromArray(atIndex: indexPath.row)
        self.treeViewDelegate?.treeView(tableView as! CITreeView, didSelectRowAt: selectedTreeViewNode!)
        var willExpandIndexPath = indexPath
        if (selectedTreeViewNode?.expand)! {
            
            self.treeViewController?.collapseRows(indexPath: indexPath, selectedTreeViewNode: selectedTreeViewNode!)
            
            if #available(iOS 11.0, *) {
                self.performBatchUpdates({
                    self.beginUpdates()
                    self.deleteRows(at: (self.treeViewController?.indexPathsArray)!, with: .automatic)
                    self.endUpdates()
                }, completion: { (complete) in
                    self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: self.selectedTreeViewNode!, atIndexPath: indexPath)
                })
            } else {
                CATransaction.begin()
                
                CATransaction.setCompletionBlock({
                    self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: self.selectedTreeViewNode!, atIndexPath: indexPath)
                })
                
                self.beginUpdates()
                self.deleteRows(at: (self.treeViewController?.indexPathsArray)!, with: .automatic)
                self.endUpdates()
                
                CATransaction.commit()
            }
        }
        else
        {
            if collapseOtherNodesWhenSelectedOneOfTheOther, selectedTreeViewNode?.level == 0 {
                let collapsedTreeViewNode = self.treeViewController?.collapseAllRows(selectedTreeViewNode: selectedTreeViewNode!)
                if (self.treeViewController?.indexPathsArray)!.count > 0 {
                    
                    
                    if #available(iOS 11.0, *) {
                        self.performBatchUpdates({
                            self.beginUpdates()
                            self.deleteRows(at: (self.treeViewController?.indexPathsArray)!, with: .automatic)
                            self.endUpdates()
                        }, completion: { (complete) in
                            self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: collapsedTreeViewNode!, atIndexPath:indexPath)
                        })
                    } else {
                        CATransaction.begin()
                        
                        CATransaction.setCompletionBlock({
                            self.treeViewDelegate?.didCollapseTreeViewNode(treeViewNode: collapsedTreeViewNode!, atIndexPath: indexPath)
                        })
                        
                        self.beginUpdates()
                        self.deleteRows(at: (self.treeViewController?.indexPathsArray)!, with: .automatic)
                        self.endUpdates()
                        
                        CATransaction.commit()
                    }
                    
                    for (index, item) in mainDataArray.enumerated() {
                        if item == selectedTreeViewNode {
                            willExpandIndexPath.row = index
                        }
                    }
                }
            }
            
            self.treeViewController?.expandRows(indexPath: willExpandIndexPath, selectedTreeViewNode: selectedTreeViewNode!)
            
            if #available(iOS 11.0, *) {
                self.performBatchUpdates({
                    self.beginUpdates()
                    self.insertRows(at: (self.treeViewController?.indexPathsArray)!, with: .automatic)
                    self.endUpdates()
                }, completion: { (complete) in
                    self.treeViewDelegate?.didExpandTreeViewNode(treeViewNode: self.selectedTreeViewNode!, atIndexPath: indexPath)
                })
            } else {
                CATransaction.begin()
                
                CATransaction.setCompletionBlock({
                    self.treeViewDelegate?.didExpandTreeViewNode(treeViewNode: self.selectedTreeViewNode!, atIndexPath: indexPath)
                })
                
                self.beginUpdates()
                self.insertRows(at: (self.treeViewController?.indexPathsArray)!, with: .automatic)
                self.endUpdates()
                
                CATransaction.commit()
            }
        }
    }
}

extension CITreeView : CITreeViewControllerDelegate {
    
    func willCollapseTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        self.treeViewDelegate?.willCollapseTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
    
    func willExpandTreeViewNode(treeViewNode: CITreeViewNode, atIndexPath: IndexPath) {
        self.treeViewDelegate?.willExpandTreeViewNode(treeViewNode: treeViewNode, atIndexPath: atIndexPath)
    }
    
    func getChildrenForTreeViewNode(withIndexPath indexPath: IndexPath, andItem item: AnyObject) -> [AnyObject] {
        return (self.treeViewDelegate?.treeViewItemChild(andItem:item))!
    }
}
