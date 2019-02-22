//
//  MachingEntriesCell.swift
//  OneDay
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

/// 검색한 문자열을 포함하는 엔트리를 보여주는 셀
class MatchingEntriesTableViewCell: UITableViewCell {
    // MARK: Properties
    // Layout Components
    private let contentsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weatherLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        label.textColor = .gray
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var contentLableTrailingConstaint: NSLayoutConstraint = contentsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: minTrailingConstant)
    
    private let marginSize: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: -8, right: -16)
    private let imageSize: CGSize = CGSize(width: 48, height: 48)
    private lazy var maxTrailingConstant: CGFloat = (self.imageSize.width * -1) + (self.marginSize.right * 2)
    private lazy var minTrailingConstant: CGFloat = self.marginSize.right
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(keyword: String, entry: Entry) {
        guard let content = entry.contents?.string else { return }
        let matchedRange = (content as NSString).range(of: keyword)
        let paragraphRange = (content as NSString).paragraphRange(for: matchedRange)
        let contentForView: String = (content as NSString).substring(with: paragraphRange)
        let colorRange = (contentForView as NSString).range(of: keyword)
        
        let attributedText = NSMutableAttributedString(string: contentForView)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.doBlue, range: colorRange)
        contentsLabel.attributedText = attributedText
        weatherLabel.text = entry.weather?.type
        
        if let fileName = entry.thumbnail {
            guard let imageURL = fileName.urlForDataStorage else { preconditionFailure("No thumbnail image") }
            
            do {
                let imageData = try Data(contentsOf: imageURL)
                thumbnailImageView.image = UIImage(data: imageData)
                contentLableTrailingConstaint.constant = maxTrailingConstant
            } catch {
                preconditionFailure("invalid ImageURL")
            }
        } else {
            thumbnailImageView.image = nil
            contentLableTrailingConstaint.constant = minTrailingConstant
        }
    }
}

extension MatchingEntriesTableViewCell {
    private func setConstraints() {
        addSubview(contentsLabel)
        addSubview(weatherLabel)
        addSubview(thumbnailImageView)
        NSLayoutConstraint.activate([
            contentsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: marginSize.left),
            contentsLabel.topAnchor.constraint(equalTo: topAnchor, constant: marginSize.top),
            contentsLabel.bottomAnchor.constraint(equalTo: weatherLabel.topAnchor, constant: -2),
            contentLableTrailingConstaint,
            
            weatherLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: marginSize.left),
            weatherLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: marginSize.bottom),
            weatherLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: maxTrailingConstant),
            
            thumbnailImageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: imageSize.height),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: marginSize.right),
            thumbnailImageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: marginSize.top),
            thumbnailImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbnailImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: marginSize.bottom)
        ])
    }
}
