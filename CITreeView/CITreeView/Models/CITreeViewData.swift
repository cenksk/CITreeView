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
        
        let subChild121 = CITreeViewData(name: "Albea")
        let subChild122 = CITreeViewData(name: "Egea")
        let subChild123 = CITreeViewData(name: "Linea")
        let subChild124 = CITreeViewData(name: "Siena")
        
        let child11 = CITreeViewData(name: "Volvo")
        let child12 = CITreeViewData(name: "Fiat", children:[subChild121, subChild122, subChild123, subChild124])
        let child13 = CITreeViewData(name: "Alfa Romeo")
        let child14 = CITreeViewData(name: "Mercedes")
        let parent1 = CITreeViewData(name: "Sedan", children: [child11, child12, child13, child14])
        
        let subChild221 = CITreeViewData(name: "Discovery")
        let subChild222 = CITreeViewData(name: "Evoque")
        let subChild223 = CITreeViewData(name: "Defender")
        let subChild224 = CITreeViewData(name: "Freelander")
        
        let child21 = CITreeViewData(name: "GMC")
        let child22 = CITreeViewData(name: "Land Rover" , children: [subChild221,subChild222,subChild223,subChild224])
        let parent2 = CITreeViewData(name: "SUV", children: [child21, child22])
        
        
        let child31 = CITreeViewData(name: "Wolkswagen")
        let child32 = CITreeViewData(name: "Toyota")
        let child33 = CITreeViewData(name: "Dodge")
        let parent3 = CITreeViewData(name: "Truck", children: [child31, child32,child33])
        
        let subChildChild5321 = CITreeViewData(name: "Carrera", children: [child31, child32,child33])
        let subChildChild5322 = CITreeViewData(name: "Carrera 4 GTS")
        let subChildChild5323 = CITreeViewData(name: "Targa 4")
        let subChildChild5324 = CITreeViewData(name: "Turbo S")
        
        let parent4 = CITreeViewData(name: "Van",children:[subChildChild5321,subChildChild5322,subChildChild5323,subChildChild5324])
        
       
        
        let subChild531 = CITreeViewData(name: "Cayman")
        let subChild532 = CITreeViewData(name: "911",children:[subChildChild5321,subChildChild5322,subChildChild5323,subChildChild5324])
        
        let child51 = CITreeViewData(name: "Renault")
        let child52 = CITreeViewData(name: "Ferrari")
        let child53 = CITreeViewData(name: "Porshe", children: [subChild531, subChild532])
        let child54 = CITreeViewData(name: "Maserati")
        let child55 = CITreeViewData(name: "Bugatti")
        let parent5 = CITreeViewData(name: "Sports Car",children:[child51,child52,child53,child54,child55])

        
        return [parent5,parent2,parent1,parent3,parent4]
    }
    
    
}
