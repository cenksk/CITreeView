//
//  CITreeViewCell.swift
//  CITreeView
//
//  Created by Apple on 24.01.2018.
//  Copyright © 2018 Cenk Işık. All rights reserved.
//

import UIKit

class CITreeViewCell: UITableViewCell {

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    let leadingValueForChildrenCell:CGFloat = 15
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(level:Int)
    {
        self.leadingConstraint.constant = leadingValueForChildrenCell * CGFloat(level - 1)
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
