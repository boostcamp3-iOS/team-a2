//
//  SideMenuMainCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuMainCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
        
    }
    
    let mainIcon: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "sideMenuFilter") ?? UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let mainLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SideMenuMainCell {
    func setupCellView() {
        addSubview(mainIcon)
        mainIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 32).isActive = true
        mainIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        mainIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(mainLabel)
        mainLabel.leftAnchor.constraint(equalTo: mainIcon.rightAnchor, constant: 32).isActive = true
        mainLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
}
