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
    var preview = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

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

    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {

        //UITextRange를 NSRange로 변경
        let startOffset: Int = textView.offset(from: textView.beginningOfDocument, to: dragRequest.dragRange.start)
        let endOffset: Int = textView.offset(from: textDraggableView.beginningOfDocument, to: dragRequest.dragRange.end)
        let offsetRange = NSRange(location: startOffset, length: endOffset - startOffset)

        let substring = textView.attributedText.attributedSubstring(from: offsetRange)

        if let attachment = substring.attributes(at: 0, effectiveRange: nil)[NSAttributedString.Key.attachment] as? NSTextAttachment, let string = textView.text(in: dragRequest.dragRange) {
            view.layoutIfNeeded()
            preview.image = attachment.image
            let itemProvider = NSItemProvider(object: string as NSString)
            let item = UIDragItem(itemProvider: itemProvider)
            return [item]
        } else {
            return [] //해당 범위 내에 이미지가 없을 시 드래그 불가
        }
    }
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        let target = UIDragPreviewTarget(container: textDraggableView, center: session.location(in: textDraggableView))
        return UITargetedDragPreview(view: preview, parameters: UIDragPreviewParameters(), target: target)

    }
}
