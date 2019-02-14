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
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let contentsListView: UITextView = {
       let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = "호랑이사자기린"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let contentsInfoView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = "감자고구마양파"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .doLight
        
        setupCellView()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectedEntriesListCell {
    fileprivate func setupCellView() {
        
        addSubview(containerView)
        containerView.leftAnchor.constraint(
            equalTo: leftAnchor,
            constant: 24).isActive = true
        containerView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 8).isActive = true
        containerView.rightAnchor.constraint(
            equalTo: rightAnchor,
            constant: -24).isActive = true
        containerView.bottomAnchor.constraint(
            equalTo: bottomAnchor).isActive = true
        
        containerView.addSubview(contentsListView)
        contentsListView.leftAnchor.constraint(
            equalTo: containerView.leftAnchor,
            constant: 8).isActive = true
        contentsListView.topAnchor.constraint(
            equalTo: containerView.topAnchor
            , constant: 8).isActive = true
        contentsListView.rightAnchor.constraint(
            equalTo: containerView.rightAnchor,
            constant: -8).isActive = true
        
        containerView.addSubview(contentsInfoView)
        contentsInfoView.leftAnchor.constraint(
            equalTo: contentsListView.leftAnchor).isActive = true
        contentsInfoView.topAnchor.constraint(
            equalTo: contentsListView.bottomAnchor,
            constant: 4).isActive = true
        contentsInfoView.rightAnchor.constraint(
            equalTo: contentsListView.rightAnchor).isActive = true
        contentsInfoView.bottomAnchor.constraint(
            equalTo: containerView.bottomAnchor,
            constant: -8).isActive = true

        contentsListView.backgroundColor = .red
        contentsInfoView.backgroundColor = .green
    }
    
}
