//
//  TimelineTableViewCell.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    let dayLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 47)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weekDayLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textColor = .lightGray
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let contentTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.textContainer.maximumNumberOfLines = 3
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let contentsInfoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let adressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let weatherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate var leftConstraintOfCell: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        setupDayLabels()
        setupThumbnailImageView()
        setupContentTextView()
        setupEntryInfoViews()
    }
    
    override func prepareForReuse() {
        dayLabel.text = ""
        weekDayLabel.text = ""
        thumbImageView.image = UIImage()
        contentTextView.text = ""
        timeLabel.text = ""
        adressLabel.text = ""
        weatherIconImageView.image = UIImage()
        weatherLabel.text = ""
        
        leftConstraintOfCell.constant = -80
        dayLabel.isHidden = true
        weekDayLabel.isHidden = true
    }
    
    func bind(entry: Entry, indexPath: IndexPath) {
        bindDate(from: entry)

        //FIXME: 날씨 아이콘 이름, 지도 기능 추가되면 수정
        adressLabel.text = "가나다라마바사아자차카타파하가나다라"
        
        if let address = entry.location?.address {
            adressLabel.text = address
        }
        
        // if let weatherIcon = entry.weather.?? {
        weatherIconImageView.image = UIImage(named: "clear-night")
        // }
        
        if let temperature = entry.weather?.tempature, let type = entry.weather?.type {
            weatherLabel.text = "\(temperature)°C \(type)"
        }
        
        bindThumbnailImage(from: entry)
    }
    
    fileprivate func bindDate(from entry: Entry) {
        let dateSet = DateStringSet(date: entry.date)
        dayLabel.text = dateSet.day
        weekDayLabel.text = dateSet.weekDay
        contentTextView.text = entry.contents?.string
        timeLabel.text = dateSet.time
    }
    
    fileprivate func bindThumbnailImage(from entry: Entry) {
        if let thumbImage = entry.thumbnail {
            guard let imageURL = thumbImage.urlForDataStorage
            else {
                preconditionFailure("No thumbnail image")
            }
            
            do {
                let imageData = try Data(contentsOf: imageURL)
                thumbImageView.image = UIImage(data: imageData)
            } catch {
                preconditionFailure("ImageData error")
            }
            leftConstraintOfCell.constant = 8
            heightAnchor.constraint(equalToConstant: 96).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TimelineTableViewCell {
    fileprivate func setupDayLabels() {
        addSubview(dayLabel)
        dayLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        dayLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(weekDayLabel)
        weekDayLabel.bottomAnchor.constraint(
            equalTo: dayLabel.topAnchor,
            constant: 8).isActive = true
        weekDayLabel.rightAnchor.constraint(
            equalTo: dayLabel.rightAnchor,
            constant: -4).isActive = true
    }
    
    fileprivate func setupThumbnailImageView() {
        let imageSize: CGFloat = 88
        addSubview(thumbImageView)
        thumbImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        thumbImageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        thumbImageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        thumbImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    fileprivate func setupContentTextView() {
        addSubview(contentTextView)
        leftConstraintOfCell = contentTextView.leftAnchor.constraint(
            equalTo: thumbImageView.rightAnchor,
            constant: -80)
        leftConstraintOfCell.isActive = true
        
        contentTextView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        contentTextView.rightAnchor.constraint(
            equalTo: dayLabel.leftAnchor,
            constant: -10).isActive = true
        contentTextView.heightAnchor.constraint(lessThanOrEqualToConstant: 90).isActive = true
    }
    
    fileprivate func setupEntryInfoViews() {
        addSubview(timeLabel)
        timeLabel.leftAnchor.constraint(equalTo: contentTextView.leftAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true

        addSubview(adressLabel)
        adressLabel.setContentCompressionResistancePriority(
            UILayoutPriority.defaultLow,
            for: .horizontal)
        
        adressLabel.leftAnchor.constraint(
            equalTo: timeLabel.rightAnchor,
            constant: 4).isActive = true
        adressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        adressLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
 
        addSubview(weatherIconImageView)
        weatherIconImageView.leftAnchor.constraint(
            equalTo: adressLabel.rightAnchor,
            constant: 8).isActive = true
        weatherIconImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        weatherIconImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        weatherIconImageView.centerYAnchor.constraint(
            equalTo: timeLabel.centerYAnchor).isActive = true

        addSubview(weatherLabel)
        weatherLabel.setContentCompressionResistancePriority(
            UILayoutPriority.defaultHigh,
            for: .horizontal)
        
        weatherLabel.leftAnchor.constraint(
            equalTo: weatherIconImageView.rightAnchor,
            constant: 4).isActive = true
        weatherLabel.rightAnchor.constraint(
            lessThanOrEqualTo: dayLabel.leftAnchor,
            constant: 16).isActive = true
        weatherLabel.widthAnchor.constraint(
            lessThanOrEqualToConstant: 50).isActive = true
        weatherLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
    }
}
