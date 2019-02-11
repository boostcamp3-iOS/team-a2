//
//  SearchedKeywordCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
//Keywords - 돋보기 + "문자열" + 일치하는 엔트리 수를 보여주는 셀
class SearchedKeywordCell: UITableViewCell {
    
    let searchIcon: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "keywordsSearch") ?? UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .doBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .doBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func bind(keyword: String?, count: Int) {
        if let keyword = keyword {
            titleLabel.text = "\"\(keyword)\""
            countLabel.text = "\(count)"
        }
    }
    
    func setupCell() {
        addSubview(searchIcon)
        searchIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        searchIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        searchIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: searchIcon.rightAnchor, constant: 16).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(countLabel)
        countLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 16).isActive = true
        countLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        countLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
