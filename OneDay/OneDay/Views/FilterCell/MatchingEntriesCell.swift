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
    // MARK: Properties
    // Layout Components
    private let matchingTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.backgroundColor = .white
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let matchingWeatherLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.callout)
        label.textColor = .gray
        return label
    }()
    
    private let matchingImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var imageWidthConstraint: NSLayoutConstraint =  matchingImageView.widthAnchor.constraint(equalToConstant: 36)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(keyword: String, entry: Entry) {
        guard let content = entry.contents?.string else { return }
        let range = (content as NSString).range(of: keyword)
        let attributedText = NSMutableAttributedString(string: content)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.doBlue, range: range)
        matchingTextLabel.attributedText = attributedText
        matchingWeatherLabel.text = entry.weather?.type
    }
}

extension MatchingEntriesCell {
    private func setupCell() {
        addSubview(matchingTextLabel)
        addSubview(matchingWeatherLabel)
        NSLayoutConstraint.activate([
            matchingTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            matchingTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            matchingTextLabel.bottomAnchor.constraint(equalTo: matchingWeatherLabel.topAnchor, constant: -2),
            matchingTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            
            matchingWeatherLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            matchingWeatherLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            matchingWeatherLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28)
        ])
    }
}
