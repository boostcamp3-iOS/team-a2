//
//  SideMenuMainCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class SideMenuFilterCell: UITableViewCell {
    // MARK: Properties
    // Layout Components
    private let iconImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageSize = CGSize(width: 22, height: 22)
    private let insets = UIEdgeInsets(top: 2, left: 24, bottom: 2, right: -16)
    
    // MARK: Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bind(type: SideMenuFilterType) {
        iconImageView.image = UIImage(named: type.iconImageName)
        titleLabel.text = type.title
    }
}

extension SideMenuFilterCell {
    private func setupCellView() {
        addSubview(iconImageView)
        iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: insets.left).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
