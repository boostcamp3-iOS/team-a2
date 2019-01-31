//
//  MachingEntriesCell.swift
//  OneDayProto
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

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

    let matchingImageView: UIImageView = {
        var imageView = UIImageView()
//        imageView.image = UIImage(named: "aaaaaaaaa")!
//        imageView.contentMode = .scaleAspectFit
//        imageView.contentMode = .left
//        let size: CGFloat = 15
//        imageView.frame = CGRect(x: 0, y: 0, width: size, height: size)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
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
