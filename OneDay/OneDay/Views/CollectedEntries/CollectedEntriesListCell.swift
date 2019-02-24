//
//  CollectedEntriesListCell.swift
//  OneDay
//
//  Created by 정화 on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class CollectedEntriesListCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .collectedEntriesListBorder
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let contentsListTextView: UITextView = {
       let textView = UITextView()
        textView.layer.cornerRadius = 3
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .doLight
        selectionStyle = .none
        setupCellView()
    }
    
    func bind(entry: Entry) {
        let attributedText = NSMutableAttributedString()
        setupAttributedText(about: entry, text: attributedText)
        resizeImageAttachment(in: attributedText)

        contentsListTextView.attributedText = attributedText
    }

    private func setupAttributedText(
        about entry: Entry,
        text attributedText: NSMutableAttributedString) {
        appendContents(entry, attributedText)
        appendJournalTitle(entry, attributedText)
        appendDate(attributedText, entry)
        appendAddress(entry, attributedText)
        appendTemperature(entry, attributedText)
    }
    
    private func appendContents(_ entry: Entry, _ attributedText: NSMutableAttributedString) {
        if let contents = entry.contents {
            attributedText.append(NSMutableAttributedString(attributedString: contents))
            attributedText.append(NSMutableAttributedString(string: "\n\n"))
        }
    }
    
    private func appendJournalTitle(_ entry: Entry, _ attributedText: NSMutableAttributedString) {
        if let title = entry.journal?.title {
            attributedText.append(NSMutableAttributedString(string: title, attributes:[
                NSAttributedString.Key.foregroundColor : UIColor.doBlue,
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]))
        }
    }
    
    private func appendDate(_ attributedText: NSMutableAttributedString, _ entry: Entry) {
        let formatter = DateFormatter.defaultInstance
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YYYY년 MM월 dd일 EEEE a hh:mm"
        
        appendDot(at: attributedText)
        attributedText.append(NSMutableAttributedString(string: formatter.string(from: entry.date)))
    }
    
    private func appendAddress(_ entry: Entry, _ attributedText: NSMutableAttributedString) {
        if let address = entry.location?.address {
            appendDot(at: attributedText)
            attributedText.append(NSMutableAttributedString(string: address))
        }
    }
    
    private func appendTemperature(_ entry: Entry, _ attributedText: NSMutableAttributedString) {
        if let temparature = entry.weather?.temperature, let type = entry.weather?.type {
            appendDot(at: attributedText)
            attributedText.append(NSMutableAttributedString(string: "\(temparature) °C  "))
            if let weatherType = WeatherType(rawValue: type) {
                attributedText.append(NSMutableAttributedString(string: weatherType.summary))
            }
        }
    }
    /**
     엔트리 콘텐츠의 어트리뷰티드 스트링에 있는 어태치먼트 이미지를 리사이즈하여 원래 있던 이미지를 교체합니다.
     - parameter attributedText: 콘텐츠의 어트리뷰티드 스트링
     */
    private func resizeImageAttachment(in attributedText: NSMutableAttributedString) {
        attributedText.enumerateAttribute(
            NSAttributedString.Key.attachment,
            in: NSRange(location: 0, length: attributedText.length),
            options: [],
            using: { value, range, _ -> Void in
                if value is NSTextAttachment {
                    guard let attachment: NSTextAttachment = value as? NSTextAttachment
                        else { return }

                    if let image = attachment.image {
                        let imageWidth = UIScreen.main.bounds.width - 124
                        
                        let newAttachment: NSTextAttachment = NSTextAttachment()
                        newAttachment.image = image.resizeImageToFit(newWidth: imageWidth)
                        attributedText.replaceCharacters(
                            in: range,
                            with: NSAttributedString(attachment: newAttachment))
                    }
                }
        })
    }
    /**
     엔트리 정보들을 구분하기 위해 텍스트에 · 을 추가합니다.
     - 엔트리 정보 사이에 사용하여 사용자가 정보를 쉽게 구분할 수 있도록 돕습니다.
     - 예) 일기 · 2019년 2월 12일 · 강남구 메리츠타워 · 맑음
     */
    private func appendDot(at attributedString: NSMutableAttributedString) {
        attributedString.append(
            NSMutableAttributedString(
                string: " · ",
                attributes: [
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectedEntriesListCell {
    private func setupCellView() {
        addSubview(containerView)
        containerView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 8).isActive = true

        containerView.leftAnchor.constraint(
            equalTo: leftAnchor,
            constant: 40).isActive = true
        containerView.bottomAnchor.constraint(
            equalTo: bottomAnchor).isActive = true
        containerView.rightAnchor.constraint(
            equalTo: rightAnchor,
            constant: -40).isActive = true
        
        containerView.addSubview(contentsListTextView)
        contentsListTextView.topAnchor.constraint(
            equalTo: containerView.topAnchor
            , constant: 1).isActive = true
        contentsListTextView.leftAnchor.constraint(
            equalTo: containerView.leftAnchor,
            constant: 1).isActive = true
        contentsListTextView.bottomAnchor.constraint(
            equalTo: containerView.bottomAnchor,
            constant: -1).isActive = true
        contentsListTextView.rightAnchor.constraint(
            equalTo: containerView.rightAnchor,
            constant: -1).isActive = true
    }
}
