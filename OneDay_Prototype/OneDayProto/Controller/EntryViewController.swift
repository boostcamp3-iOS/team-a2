//
//  EntryViewController.swift
//  OneDayProto
//
//  Created by juhee on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices

class EntryViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!

    var entry: EntryVO?
    weak var delegate: EntryDelegate!

    //드레그시 사용되는 이미지뷰
    let previewImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    let preview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width/2).isActive = true
        view.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        view.backgroundColor = UIColor(white: 1, alpha: 0.7)
        view.layer.cornerRadius = 20
        return view
    }()

    func getPreviewLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    func setupPreview(_ previewLabel: UILabel) {
        if preview.subviews.count != 0 {
            preview.subviews[0].removeFromSuperview()
        }
        preview.addSubview(previewLabel)
        previewLabel.topAnchor.constraint(equalTo: preview.topAnchor, constant: 8).isActive = true
            previewLabel.bottomAnchor.constraint(equalTo: preview.bottomAnchor, constant: -8).isActive = true
            previewLabel.leftAnchor.constraint(equalTo: preview.leftAnchor, constant: 8).isActive = true
            previewLabel.rightAnchor.constraint(equalTo: preview.rightAnchor, constant: -8).isActive = true
    }

    lazy var isSelectedImage = false
    lazy var selectedText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        var dateSet: DateStringSet = DateStringSet(date: Date())
        if let data = entry {
            dateSet = DateStringSet(date: data.date)
            textView.text = data.title
        }

        dateLabel.text = dateSet.full
        timeLabel.text = dateSet.time
        textView.textDragDelegate = self
    }

    @IBAction func showPhoto(_ sender: UIButton) {
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.sourceType = .photoLibrary
        pickerViewController.allowsEditing = true
        present(pickerViewController, animated: true, completion: nil)
    }

    @IBAction func saveAndDismiss(_ sender: UIButton) {
        guard let content = textView.text else {
            return
        }
        if let entry = entry {
            delegate.update(entry: entry)
        } else {
            let journal = Journal.init(id: 0, title: "일지이", index: 0, entryCount: 0, entries: [])

            let newEntry = EntryVO.init(id: 1, contents: [], updatedDate: Date(), date: Date(), isFavorite: false, journal: journal, location: nil, tags: ["태그1", "태그2"], deviceId: "1", title: content)

            delegate.register(new: newEntry)
        }

        dismiss(animated: true, completion: nil)
    }

}

extension EntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

extension EntryViewController: UITextDragDelegate, UITextDropDelegate {

    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        // 드래그 위치를 얻음
        let dragPoint = session.location(in: textDraggableView)
        print(dragPoint)
        // 드래그 프리뷰가 시작될 위치를 지정
        let target = UIDragPreviewTarget(container: textView, center: dragPoint)

        // 이미지가 선택되었는가? 선택되었으면 이미지뷰 반환, 아니면 텍스트 라벨 반환
        if isSelectedImage {
            isSelectedImage = false
            return UITargetedDragPreview(view: previewImageView, parameters: UIDragPreviewParameters(), target: target)
        } else {
            let previewLabel = getPreviewLabel(text: selectedText)
            setupPreview(previewLabel)
            return UITargetedDragPreview(view: preview, parameters: UIDragPreviewParameters(), target: target)
        }
    }

    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        // UITextRange를 NSRange로 변경
        let startOffset: Int = textView.offset(from: textView.beginningOfDocument,
                                               to: dragRequest.dragRange.start)
        let endOffset: Int = textView.offset(from: textDraggableView.beginningOfDocument,
                                             to: dragRequest.dragRange.end)
        let offsetRange = NSRange(location: startOffset, length: endOffset - startOffset)

        let substring = textView.attributedText.attributedSubstring(from: offsetRange)

        // attributedText에 이미지가 있으면 previewImageView에 이미지를 저장하고 isSelectedImage을 true로 바꾼다
        if let attachment = substring.attributes(at: 0, effectiveRange: nil)[NSAttributedString.Key.attachment] as? NSTextAttachment {
            previewImageView.image = attachment.image
            isSelectedImage = true
        }

        if let selectedString = textView.text(in: dragRequest.dragRange) {
            //            텍스트를 저장할 라벨을 초기화하고, 선택된 범위의 텍스트를 집어넣음, 이미지를 선택하면 selectedString == "" 이다
            selectedText = ""
            selectedText = selectedString

            let itemProvider = NSItemProvider(object: selectedString as NSString)
            let item = UIDragItem(itemProvider: itemProvider)
            return [item]
        } else {
            return []
        }
    }
}
