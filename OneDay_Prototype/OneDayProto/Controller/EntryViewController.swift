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

    var entry: Entry!

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
    }

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
        if let string = textView.text(in: dragRequest.dragRange) {
            let itemProvider = NSItemProvider(object: string as NSString)
            let item = UIDragItem(itemProvider: itemProvider)
            item.localObject = true
            return [item]
        } else {
            return []
        }
    }
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {

        let center = CGPoint(x: textView.bounds.midX, y: textView.bounds.midY)
        let target = UIDragPreviewTarget(container: textView, center: center)
        return UITargetedDragPreview(view: textDraggableView.subviews[1], parameters: UIDragPreviewParameters(), target: target)

    }
}
