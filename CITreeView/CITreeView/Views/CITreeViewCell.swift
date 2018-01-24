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
    @IBOutlet weak var avatarImageView: UIImageView!
    
    let leadingValueForChildrenCell:CGFloat = 30
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(level:Int)
    {
        self.leadingConstraint.constant = leadingValueForChildrenCell * CGFloat(level + 1)
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2
        
        self.avatarImageView.backgroundColor = getRandomColor()
        
        self.layoutIfNeeded()
    }
    
    func getRandomColor() -> UIColor{
        
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
