//
//  CITreeViewNode.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

class CITreeViewNode: NSObject {
    var expand:Bool = false
    var level:Int = 0
    var item:AnyObject
    
    init(item:AnyObject) {
        self.item = item
    }
}
