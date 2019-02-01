//
//  FilterTableCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

//Filter - Favorite, 체크리스트, 태그...를 위한 셀
class FilterTableCell: UITableViewCell {

    let filterIcon: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "sideMenuFilter") ?? UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter"
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contentsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func bind(filter filterItem: (name: String, image: String, count: Int)) {
        selectionStyle = .none
        filterIcon.image = UIImage(named: filterItem.image)
        filterLabel.text = filterItem.name
        contentsCountLabel.text = "\(filterItem.count)"
    }
    
    func setupCell() {
        addSubview(filterIcon)
        filterIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        filterIcon.widthAnchor.constraint(equalToConstant: 24)
        filterIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(filterLabel)
        filterLabel.leftAnchor.constraint(equalTo: filterIcon.rightAnchor, constant: 24).isActive = true
        filterLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(contentsCountLabel)
        contentsCountLabel.leftAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        contentsCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
