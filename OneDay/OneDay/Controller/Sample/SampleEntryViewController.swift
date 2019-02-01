//
//  SampleEntryViewController.swift
//  OneDay
//
//  Created by juhee on 31/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices

class SampleEntryViewController: UIViewController {
    
    // MARK: - properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var entry: Entry!
    
    //드레그시 사용되는 미리보기
    let imagePreview = UIImageView()
    let textPreview = UIView()
    let previewLabel = UILabel()
    
    lazy var isImageSelected = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var dateSet: DateStringSet = DateStringSet(date: Date())
        if let data = entry {
            dateSet = DateStringSet(date: data.date)
            textView.attributedText = data.contents
        }
        
        dateLabel.text = dateSet.full
        timeLabel.text = dateSet.time
        textView.textDragDelegate = self
        
        setUpPreview()
    }
    
    // MARK: - Setup
    func setUpPreview() {
        imagePreview.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        textPreview.backgroundColor = UIColor(white: 1, alpha: 0.7)
        textPreview.layer.cornerRadius = 20
        textPreview.translatesAutoresizingMaskIntoConstraints = false
        textPreview.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width/2).isActive = true
        textPreview.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        textPreview.addSubview(previewLabel)
        
        previewLabel.textAlignment = .left
        previewLabel.numberOfLines = 0
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.topAnchor.constraint(equalTo: textPreview.topAnchor, constant: 8).isActive = true
        previewLabel.bottomAnchor.constraint(equalTo: textPreview.bottomAnchor, constant: -8).isActive = true
        previewLabel.leftAnchor.constraint(equalTo: textPreview.leftAnchor, constant: 8).isActive = true
        previewLabel.rightAnchor.constraint(equalTo: textPreview.rightAnchor, constant: -8).isActive = true
    }
    
    // MARK: - IBAction
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
        
        let title: String
        let stringContent = content.string
        if stringContent.count > 1 {
            let start = stringContent.startIndex
            let end = stringContent.index(start, offsetBy: min(stringContent.count - 1, 40))
            title = String(stringContent[start...end])
        } else {
            title = "새로운 엔트리"
        }
        
        entry.title = title
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Extention
extension SampleEntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        insertAtTextViewCursor(attributedString: createAttributedString(with: image))
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapAndHideKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    fileprivate func createAttributedString(with image: UIImage) -> NSAttributedString {
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width
        let scaleFactor = oldWidth / (textView.frame.size.width - 10)
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        return attrStringWithImage
    }
    
    fileprivate func insertAtTextViewCursor(attributedString: NSAttributedString) {
        guard let selectedRange = textView.selectedTextRange else {
            return
        }
        
        // If here, insert <attributedString> at cursor
        let cursorIndex = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
        let mutableAttributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableAttributedText.insert(attributedString, at: cursorIndex)
        textView.attributedText = mutableAttributedText
    }
}

extension SampleEntryViewController: UITextDragDelegate {
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        // 드래그 프리뷰가 시작될 위치
        let target = UIDragPreviewTarget(container: textView, center: session.location(in: textDraggableView))
        
        if isImageSelected {
            isImageSelected = false
            return UITargetedDragPreview(view: imagePreview, parameters: UIDragPreviewParameters(), target: target)
        } else {
            return UITargetedDragPreview(view: textPreview, parameters: UIDragPreviewParameters(), target: target)
        }
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        
        if let selectedText = textView.text(in: dragRequest.dragRange) {
            
            // UITextRange를 NSRange로 변경
            let startOffset: Int = textView.offset(from: textView.beginningOfDocument,
                                                   to: dragRequest.dragRange.start)
            let endOffset: Int = textView.offset(from: textDraggableView.beginningOfDocument,
                                                 to: dragRequest.dragRange.end)
            let offsetRange = NSRange(location: startOffset, length: endOffset - startOffset)
            
            let substring = textView.attributedText.attributedSubstring(from: offsetRange)
            
            if let attachment = substring.attributes(at: 0, effectiveRange: nil)[NSAttributedString.Key.attachment] as? NSTextAttachment {
                //드래그 요소가 이미지인 경우
                imagePreview.image = attachment.image
                isImageSelected = true
            } else {
                //드래그 요소가 텍스트인 경우
                previewLabel.text = selectedText
            }
            
            let itemProvider = NSItemProvider(object: selectedText as NSString)
            return [UIDragItem(itemProvider: itemProvider)]
        } else {
            return []
        }
    }
}
