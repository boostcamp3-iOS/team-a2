//
//  EditorSettingTableViewCell.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 2. 13..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit

class EditorSettingTableViewCell: UITableViewCell {
    
    var setting: Setting! {
        didSet {
            textLabel?.text = setting.title
            detailTextLabel?.text = setting.detail
            imageView?.image = setting.image
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.systemFont(ofSize: 12)
        textLabel?.textColor = UIColor.doBlue
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
