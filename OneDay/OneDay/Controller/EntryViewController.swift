//
//  EntryViewController.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import CoreData
import MobileCoreServices
import UIKit

class EntryViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomContainerView: UIView!
    
    var entry: Entry!
    
    ///드레그시 사용되는 미리보기 뷰
    let imagePreview = UIImageView()
    let textPreview = UIView()
    let previewLabel = UILabel()
    
    lazy var isImageSelected = false
    
    ///하단 뷰 드래그시 사용되는 프로퍼티
    var topConstant: CGFloat = 0            /// 하단 뷰 최상단
    var bottomConstant: CGFloat = 520       /// 하단 뷰 최하단
    var dragUpChangePoint: CGFloat = 400    ///하단 뷰 위로 드래그시 위로 붙는 기준
    var isBottom = true                     ///하단 뷰가 아래에 있는지 여부
    var willPositionChange = false          ///드래그 종료시 변경되야하는지 여부
    
    let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
    
    fileprivate var bottomViewTopConstraint: NSLayoutConstraint!
    fileprivate var bottomViewBottomConstraint: NSLayoutConstraint!
    
    var bottomViewController: EntryInformationViewController!
    weak var statusChangeDelegate: StateChangeDelegate?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textDragDelegate = self

        setUpDate()
        setUpPreview()
        setUpBottomView()
    }
    
    // MARK: - Setup
    
    func setUpDate() {
        var dateSet: DateStringSet = DateStringSet(date: Date())
        if let entry = entry {
            dateSet = DateStringSet(date: entry.date)
            textView.attributedText = entry.contents
        }
        dateLabel.text = dateSet.full
    }
    
    func setUpPreview() {
        imagePreview.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        textPreview.backgroundColor = UIColor(white: 1, alpha: 0.7)
        textPreview.layer.cornerRadius = 20
        textPreview.translatesAutoresizingMaskIntoConstraints = false
        textPreview.widthAnchor.constraint(
            lessThanOrEqualToConstant: UIScreen.main.bounds.width/2
        ).isActive = true
        textPreview.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        textPreview.addSubview(previewLabel)
        
        previewLabel.textAlignment = .left
        previewLabel.numberOfLines = 0
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.topAnchor.constraint(
            equalTo: textPreview.topAnchor,
            constant: 8
        ).isActive = true
        previewLabel.bottomAnchor.constraint(
            equalTo: textPreview.bottomAnchor,
            constant: -8
        ).isActive = true
        previewLabel.leftAnchor.constraint(
            equalTo: textPreview.leftAnchor,
            constant: 8
        ).isActive = true
        previewLabel.rightAnchor.constraint(
            equalTo: textPreview.rightAnchor,
            constant: -8
        ).isActive = true
    }
    
    func setUpBottomView() {
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomViewTopConstraint = bottomContainerView.topAnchor.constraint(
            equalTo: topView.bottomAnchor,
            constant: bottomConstant
        )
        bottomViewTopConstraint.isActive = true
        bottomViewBottomConstraint = bottomContainerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: bottomConstant
        )
        bottomViewBottomConstraint.isActive = true
        
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(didDrag(gestureRecognizer:))
        )
        bottomContainerView.addGestureRecognizer(gesture)
        bottomContainerView.isUserInteractionEnabled = true
    }
    
    func showAlert(title: String = "", message: String = "") {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "확인",
            style: .default,
            handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Actions
    @IBAction func showPhoto(_ sender: UIButton) {
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.sourceType = .photoLibrary
        pickerViewController.allowsEditing = true
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveAndDismiss(_ sender: UIButton) {
        guard let content = textView.attributedText else {
            return
        }
        entry.contents = content
        
        let stringContent = content.string
        if stringContent.count > 1 {
            let start = stringContent.startIndex
            let end = stringContent.index(start, offsetBy: min(stringContent.count - 1, 40))
            entry.title = String(stringContent[start...end])
        }
        
        entry.updatedDate = Date()
        
        if let thumbnailImage = content.firstImage {
            entry.thumbnail = thumbnailImage.saveToFile()
        } else {
            entry.thumbnail = nil
        }
        
        CoreDataManager.shared.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Gesture
    
    @objc func didDrag(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: view)
            var distance = translation.y + bottomConstant
            distance = min(bottomConstant, distance)
            distance = max(topConstant, distance)
        
            bottomViewTopConstraint.constant = distance
            bottomViewBottomConstraint.constant = distance
            
            if !willPositionChange && distance <= dragUpChangePoint {
                willPositionChange = true
                generator.impactOccurred()
            } else if willPositionChange && distance > dragUpChangePoint {
                willPositionChange = false
                generator.impactOccurred()
            }
        } else if gestureRecognizer.state == .ended {
            changeBottomTableViewConstraints()
        }
    }
    
    func changeBottomTableViewConstraints() {
        if isBottom, willPositionChange {
            isBottom = false
            statusChangeDelegate?.changeState()
            bottomContainerView.gestureRecognizers?.removeLast()
            self.bottomViewTopConstraint.constant = self.topConstant
            self.bottomViewBottomConstraint.constant = self.topConstant
        } else {
            isBottom = true
            self.bottomViewTopConstraint.constant = self.bottomConstant
            self.bottomViewBottomConstraint.constant = self.bottomConstant
        }
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.view.layoutIfNeeded()
        },
            completion: nil
        )
        willPositionChange = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bottomViewSegue" {
            if let bottomViewController = segue.destination as? EntryInformationViewController {
                bottomViewController.entryViewController = self
                statusChangeDelegate = bottomViewController
                bottomViewController.statusChangeDelegate = self
            }
        }
    }
}

// MARK: - Extention

extension EntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        var pickedImage: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            pickedImage = editedImage
        } else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            pickedImage = originImage
        }
        
        if let pickedImage = pickedImage {
            let originWidth = pickedImage.size.width
            let scaleFactor = originWidth / (textView.frame.size.width - 10)
            let scaledImage =  UIImage(cgImage: pickedImage.cgImage!, scale: scaleFactor, orientation: .up)
            insertAtTextViewCursor(attributedString: scaledImage.attributedString)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hideKeyboardDidTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    fileprivate func insertAtTextViewCursor(attributedString: NSAttributedString) {
        guard let selectedRange = textView.selectedTextRange else {
            return
        }
        
        /// attributedString을 cursor위치에 넣는다.
        let cursorIndex = textView.offset(
            from: textView.beginningOfDocument,
            to: selectedRange.start
        )
        let mutableAttributedText = NSMutableAttributedString(
            attributedString: textView.attributedText
        )
        mutableAttributedText.insert(attributedString, at: cursorIndex)
        textView.attributedText = mutableAttributedText
    }
}

extension EntryViewController: UITextDragDelegate {
    
    func textDraggableView(
        _ textDraggableView: UIView & UITextDraggable,
        dragPreviewForLiftingItem item: UIDragItem,
        session: UIDragSession
    ) -> UITargetedDragPreview? {
        
        /// 드래그 프리뷰가 시작될 위치
        let target = UIDragPreviewTarget(
            container: textView,
            center: session.location(in: textDraggableView)
        )
        
        if isImageSelected {
            isImageSelected = false
            return UITargetedDragPreview(
                view: imagePreview,
                parameters: UIDragPreviewParameters(),
                target: target
            )
        } else {
            return UITargetedDragPreview(
                view: textPreview,
                parameters: UIDragPreviewParameters(),
                target: target
            )
        }
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        
        if let selectedText = textView.text(in: dragRequest.dragRange) {
            /// UITextRange를 NSRange로 변경
            let startOffset: Int = textView.offset(
                from: textView.beginningOfDocument,
                to: dragRequest.dragRange.start
            )
            let endOffset: Int = textView.offset(
                from: textDraggableView.beginningOfDocument,
                to: dragRequest.dragRange.end
            )
            let offsetRange = NSRange(location: startOffset, length: endOffset - startOffset)
            let substring = textView.attributedText.attributedSubstring(from: offsetRange)
            
            if let attachment = substring.attributes(
                at: 0,
                effectiveRange: nil
            )[NSAttributedString.Key.attachment] as? NSTextAttachment {
                ///선택된 것이 이미지인 경우
                imagePreview.image = attachment.image
                isImageSelected = true
            } else {
                ///선택된 것이 텍스트인 경우
                previewLabel.text = selectedText
            }
            
            let itemProvider = NSItemProvider(object: selectedText as NSString)
            return [UIDragItem(itemProvider: itemProvider)]
        } else {
            return []
        }
    }
}

extension EntryViewController: StateChangeDelegate {
    func changeState() {
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(didDrag(gestureRecognizer:))
        )
        bottomContainerView.addGestureRecognizer(gesture)
        changeBottomTableViewConstraints()
    }
}
