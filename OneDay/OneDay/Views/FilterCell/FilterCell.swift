//
//  FilterCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

//Filter - Favorite, 체크리스트, 태그...를 위한 셀
class FilterCell: UITableViewCell {

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
    
    func bind(filter type: FilterTableCellType, count: Int) {
        selectionStyle = .none
        filterIcon.image = type.icon
        filterLabel.text = type.title
        contentsCountLabel.text = "\(count)"
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

enum FilterTableCellType: Hashable, CaseIterable {
    
    case favorite
    case tag
    case location
    case year
    case weather
    case device
    
    var title: String {
        switch self {
        case .favorite:
            return "즐겨찾기"
        case .tag:
            return "태그"
        case .location:
            return "장소"
        case .year:
            return "연도"
        case .weather:
            return "날씨"
        case .device:
            return "작성 디바이스"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .favorite:
            return UIImage(named: "filterHeart")
        case .tag:
            return UIImage(named: "filterTag")
        case .location:
            return UIImage(named: "filterPlace")
        case .year:
            return UIImage(named: "filterHeart")
        case .weather:
            return UIImage(named: "filterWeather")
        case .device:
            return UIImage(named: "filterDevice")
        }
    }
}
