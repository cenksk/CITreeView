//
//  CITreeViewData.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

class CITreeViewData {
    
    let name : String
    var children : [CITreeViewData]
    
    init(name : String, children: [CITreeViewData]) {
        self.name = name
        self.children = children
    }
    
    convenience init(name : String) {
        self.init(name: name, children: [CITreeViewData]())
    }
    
    func addChild(_ child : CITreeViewData) {
        self.children.append(child)
    }
    
    func removeChild(_ child : CITreeViewData) {
        self.children = self.children.filter( {$0 !== child})
    }
}

extension CITreeViewData {
    
    static func getDefaultCITreeViewData() -> [CITreeViewData] {
        let child11 = CITreeViewData(name: "Child 1.1")
        let child12 = CITreeViewData(name: "Child 1.2")
        let child13 = CITreeViewData(name: "Child 1.3")
        let child14 = CITreeViewData(name: "Child 1.4")
        let parent1 = CITreeViewData(name: "Parent 1", children: [child11, child12, child13, child14])
        
        
        let child21 = CITreeViewData(name: "Child 2.1")
        let child22 = CITreeViewData(name: "Child 2.2")
        let parent2 = CITreeViewData(name: "Parent 2", children: [child21, child22])
        
        
        let subChild321 = CITreeViewData(name: "Child 3.2.1")
        let subChild322 = CITreeViewData(name: "Child 3.2.2")
        let subChild323 = CITreeViewData(name: "Child 3.2.3")
        let subChild324 = CITreeViewData(name: "Child 3.2.4")
        
        let child31 = CITreeViewData(name: "Child 3.1")
        let child32 = CITreeViewData(name: "Child 3.2", children: [subChild321, subChild322,subChild323,subChild324])
        let child33 = CITreeViewData(name: "Child 3.3")
        let parent3 = CITreeViewData(name: "Parent 3", children: [child31, child32,child33])
        
        let parent4 = CITreeViewData(name: "Parent 4")
        
        let subChildChild5321 = CITreeViewData(name: "Child 5.3.2.1")
        let subChildChild5322 = CITreeViewData(name: "Child 5.3.2.2")
        let subChildChild5323 = CITreeViewData(name: "Child 5.3.2.3")
        let subChildChild5324 = CITreeViewData(name: "Child 5.3.2.4")
        
        let subChild531 = CITreeViewData(name: "Child 5.3.1")
        let subChild532 = CITreeViewData(name: "Child 5.3.2",children:[subChildChild5321,subChildChild5322,subChildChild5323,subChildChild5324])
        
        let child51 = CITreeViewData(name: "Child 5.1")
        let child52 = CITreeViewData(name: "Child 5.2")
        let child53 = CITreeViewData(name: "Child 5.3", children: [subChild531, subChild532])
        let child54 = CITreeViewData(name: "Child 5.4")
        let child55 = CITreeViewData(name: "Child 5.5")
        let parent5 = CITreeViewData(name: "Parent 5",children:[child51,child52,child53,child54,child55])

        
        return [parent1,parent2,parent3,parent4,parent5]
    }
}
