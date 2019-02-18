//
//  CollectedEntriesListCell.swift
//  OneDay
//
//  Created by 정화 on 14/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class CollectedEntriesListCell: UITableViewCell {
    let containerView: UIView = {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectedEntriesListCell {
    fileprivate func setupCellView() {
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

class AAAttachment : NSTextAttachment {

    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {

        guard let image = self.image else {
            return CGRect.zero
        }

        let height = lineFrag.size.height

        var scalingFactor = CGFloat(20)
        print(lineFrag)
        let imageSize = image.size
        if height < imageSize.height {
            scalingFactor *= height / imageSize.height
        }
        let rect = CGRect(x: 0, y: 0, width: imageSize.width * scalingFactor, height: imageSize.height * scalingFactor)

        return rect
    }

}
