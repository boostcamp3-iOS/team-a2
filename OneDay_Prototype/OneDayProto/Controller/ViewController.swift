//
//  ViewController.swift
//  OneDayProto
//
//  Created by juhee on 22/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    let textView = UITextView(frame: CGRect(x: 0, y: 70, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 50))

    let attachment = NSTextAttachment()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = true

        textView.text = "The UITextField and UITextView classes provide built-in support for draggin\ntems with your custom data types."
        let firstString = NSMutableAttributedString(string: textView.text)
        //FIXME: 아래에 본인의 이미지 소스 넣어서 테스트
        attachment.image = UIImage(named: "like")
        let iconString = NSAttributedString(attachment: attachment)
        firstString.append(iconString)
        textView.attributedText = firstString
        textView.textDragDelegate = self
        textView.isEditable = true
    }
}

extension ViewController: UITextDragDelegate {
//    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
//        guard let attedText = textView.attributedText else { return [] }
//
//        let provider = NSItemProvider(object: attedText)
//        let item = UIDragItem(itemProvider: provider)
//        item.localObject = attedText
//
//        return [item]
//    }

    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {

        let target = UIDragPreviewTarget(container: textDraggableView, center: session.location(in: textDraggableView))

        // view에 다른 view 넣어야함
        return UITargetedDragPreview(view: self.view, parameters: UIDragPreviewParameters(), target: target)
    }

    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {

        if let string = textView.text(in: dragRequest.dragRange) {
            let itemProvider = NSItemProvider(object: string as NSString)
            return [UIDragItem(itemProvider: itemProvider)]
        } else {
            return []
        }
    }
}

//extension ViewController: UIDropInteractionDelegate {
//    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
//        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
//    }
//
//    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
//        let dropLocation = session.location(in: view)
//        let operation: UIDropOperation
//        if textView.frame.contains(dropLocation) {
//            operation = session.localDragSession == nil ? .copy : .move
//        } else {
//            operation = .cancel
//        }
//        return UIDropProposal(operation: operation)
//    }
//
//    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
//        session.loadObjects(ofClass: NSAttributedString.self) { attStrings in
//            guard let attStirng = attStrings as? [NSAttributedString] else { return }
//
//            self.textView.attributedText = attStirng.first
//        }
//    }
//}
