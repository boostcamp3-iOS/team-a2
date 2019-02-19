//
//  SideMenuMainCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuFilterCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    let mainIcon: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let mainLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageSize = CGSize(width: 22, height: 22)
    private let insets = UIEdgeInsets(top: 2, left: 24, bottom: 2, right: -16)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SideMenuFilterCell {
    func setupCellView() {
        addSubview(mainIcon)
        mainIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left).isActive = true
        mainIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mainIcon.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        mainIcon.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        
        addSubview(mainLabel)
        mainLabel.leftAnchor.constraint(equalTo: mainIcon.rightAnchor, constant: insets.left).isActive = true
        mainLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right).isActive = true
        mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        }
    
    func bind(type: SideMenuFilterCellType) {
        mainIcon.image = UIImage(named: type.icon)
        mainLabel.text = type.title
    }
}
