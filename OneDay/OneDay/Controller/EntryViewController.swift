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
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomContainerView: UIView!
  
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    var entry: Entry!
    
    ///드레그시 사용되는 미리보기 뷰
    private let imagePreview = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    private let textPreview = UIView()
    private let previewLabel = UILabel()
    
    private var isImageSelected = false
    private var shouldSaveEntry = false
    
    ///하단 뷰 드래그시 사용되는 프로퍼티
    private var topConstant: CGFloat = 0            /// 하단 뷰 최상단
    private var bottomConstant: CGFloat = 520       /// 하단 뷰 최하단
    private var dragUpChangePoint: CGFloat = 400    ///하단 뷰 위로 드래그시 위로 붙는 기준
    private var isBottom = true                     ///하단 뷰가 아래에 있는지 여부
    private var willPositionChange = false          ///드래그 종료시 변경되야하는지 여부
    
    private let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
    
    fileprivate var bottomViewTopConstraint: NSLayoutConstraint!
    fileprivate var bottomViewBottomConstraint: NSLayoutConstraint!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private weak var statusChangeDelegate: StateChangeDelegate?
    
    private var keyboadrdToolbar: UIToolbar?
    var viewHeightWithoutTopView: CGFloat = 0
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setUpDate()
        setUpPreview()
        setUpBottomView()
        registerForKeyboardNotifications()
    }
    
    // MARK: - Bind Data to View
    private func bind() {
        textView.attributedText = entry.contents
        textView.textDragDelegate = self
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    private func setUpDate() {
        let dateSet: DateStringSet = DateStringSet(date: entry.date)
        dateLabel.text = dateSet.full
    }
    
    private func setUpPreview() {
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
    
    private func setUpBottomView() {
        viewHeightWithoutTopView = view.bounds.height - topView.frame.maxY
        bottomConstant = viewHeightWithoutTopView * 0.82
        textViewBottomConstraint.constant = bottomConstant
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
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func showAlert(title: String = "", message: String = "") {
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
}

// MARK: - Extention
// MARK: IBActions
extension EntryViewController {
    @IBAction func showPhoto(_ sender: UIButton) {
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.sourceType = .photoLibrary
        pickerViewController.allowsEditing = true
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        textView.endEditing(false)
        if shouldSaveEntry {
            self.blockView.isHidden = false
            
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                    self.activityIndicatorView.startAnimating()
                    self.blockView.alpha = 1
                })
            }, completion: { _ in
                guard let contents = self.textView.attributedText else { return }
                
                // 이미지 파일 변환 및 파일로 저장, CoreData 저장
                self.entry.contents = contents
                self.entry.updatedDate = Date()
                
                // title로 사용할 string 추출
                let stringContent = contents.string
                if stringContent.count > 1 {
                    let start = stringContent.startIndex
                    let end = stringContent.index(start, offsetBy: min(stringContent.count - 1, Constants.maximumNumberOfEntryTitle))
                    self.entry.title = String(stringContent[start...end])
                }
                
                // thumbnail image 추출
                if let thumbnailImage = contents.firstImage {
                    self.entry.thumbnail = thumbnailImage.saveToFile(fileName: self.entry.thmbnailFileName)
                } else {
                    self.entry.thumbnail = nil
                }
                CoreDataManager.shared.save(successHandler: {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.activityIndicatorView.stopAnimating()
                        self.checkImageView.isHidden = false
                        self.checkImageView.alpha = 1
                    }, completion: { _ in
                        self.dismiss(animated: true, completion: nil)
                    })
                }, errorHandler: { _ in
                    let alert = UIAlertController(title: "저장 실패", message: "다시 시도해주세요", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel , handler: { _ in
                        self.blockView.isHidden = true
                    }))
                    self.present(alert, animated: true)
                })
            })
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
        CoreDataManager.shared.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Gesture
    
    @objc private func didDrag(gestureRecognizer: UIPanGestureRecognizer) {
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
    
    private func changeBottomTableViewConstraints() {
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
                bottomViewController.entry = entry
                bottomViewController.topViewDateLabel = dateLabel
                bottomViewController.topViewFavoriteImage = favoriteImage
                statusChangeDelegate = bottomViewController
                bottomViewController.statusChangeDelegate = self
            }
        }
    }
}

// MARK: UITextViewDelegate
extension EntryViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        shouldSaveEntry = true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if keyboadrdToolbar == nil {
            keyboadrdToolbar = UIToolbar.init(frame:
                CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
            let hideKeyboardButton = UIBarButtonItem.init(
                title: "Submit",
                style: .plain,
                target: self,
                action: #selector(hideKeyboard))
            hideKeyboardButton.image = UIImage(named: "ic_down")
            keyboadrdToolbar?.tintColor = UIColor.doGray
            keyboadrdToolbar?.backgroundColor = UIColor.white
            keyboadrdToolbar?.items = [hideKeyboardButton]
            textView.inputAccessoryView = keyboadrdToolbar
        }
        return true
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
            let scaleFactor = originWidth / (textView.frame.size.width - Constants.imageScaleConstantForTextView)
            let scaledImage =  UIImage(cgImage: pickedImage.cgImage!, scale: scaleFactor, orientation: .up)
            insertAtTextViewCursor(attributedString: scaledImage.attributedString)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func insertAtTextViewCursor(attributedString: NSAttributedString) {
        guard let selectedRange = textView.selectedTextRange else { return }
        /// attributedString을 cursor위치에 넣는다.
        let cursorIndex = textView.offset(
            from: textView.beginningOfDocument,
            to: selectedRange.start
        )
        let mutableAttributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableAttributedText.insert(attributedString, at: cursorIndex)
        textView.attributedText = mutableAttributedText
    }
}

// MARK: UITextDragDelegate
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
            isImageSelected.toggle()
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

// MARK: Keyboard

extension EntryViewController {
    
    @objc private func hideKeyboard() {
        textView.endEditing(false)
    }
    
    @objc private func keyboardWasShown(_ notification: Notification?) {
        if let keyboardFrame: NSValue = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight - (viewHeightWithoutTopView * 0.14), right: 0.0)
            textView.contentInset = contentInsets
            textView.scrollIndicatorInsets = contentInsets
            
            var viewFrame: CGRect = view.frame
            viewFrame.size.height -= keyboardHeight - (viewHeightWithoutTopView * 0.14)
            if !viewFrame.contains(textView.frame.origin) {
                textView.scrollRectToVisible(textView.frame, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillBeHidden(_ aNotification: Notification?) {
        let contentInsets: UIEdgeInsets = .zero
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
    }
}
