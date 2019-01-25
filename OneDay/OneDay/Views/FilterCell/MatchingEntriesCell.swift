//
//  MachingEntriesCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
//Matching Entries - SearchBar.text와 일치하는 문자열이 있는 엔트리를 보여주는 셀
class MatchingEntriesCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    let matchingTextLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 3
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let matchingWeatherLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //FIXME: 엔트리에 이미지가 있으면 보이도록 추가해야 함
    let matchingImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MatchingEntriesCell {
    func setupCell() {
        addSubview(matchingTextLabel)
        matchingTextLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        matchingTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        matchingTextLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        
        addSubview(matchingWeatherLabel)
        matchingWeatherLabel.leftAnchor.constraint(equalTo: matchingTextLabel.leftAnchor, constant: 0).isActive = true
        matchingWeatherLabel.topAnchor.constraint(equalTo: matchingTextLabel.bottomAnchor, constant: 8).isActive = true
        matchingWeatherLabel.rightAnchor.constraint(equalTo: matchingTextLabel.rightAnchor, constant: 0).isActive = true
        
    }
}
