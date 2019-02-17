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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var entry: Entry!
    
    ///드레그시 사용되는 미리보기 뷰
    private let imagePreview = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    private let textPreview = UIView()
    private let previewLabel = UILabel()
    
    lazy var isImageSelected = false
    private var shouldSaveEntry = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPreview()
        bind()
    }
    
    // MARK: - Bind Data to View
    private func bind() {
        textView.attributedText = entry.contents
        textView.textDragDelegate = self
        textView.delegate = self
        
        if entry != nil {
            setUpDate()
            setUpWeather()
        }
    }
    
    func setUpDate() {
        let dateSet: DateStringSet = DateStringSet(date: entry.date)
        dateLabel.text = dateSet.full
        timeLabel.text = dateSet.time
    }
    
    func setUpPreview() {
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
    
    func setUpWeather() {
        if let weather = entry.weather {
            temperatureLabel.text = "\(weather.tempature)℃"
            guard let type = weather.type else { return }
            weatherImageView.image = UIImage(named: type)
            weatherLabel.text = WeatherType(rawValue: type)?.summary
        } else {
            let weather = CoreDataManager.shared.weather()
            WeatherService.service.weather(
                latitude: LocationService.service.latitude,
                longitude: LocationService.service.longitude,
                success: {[weak self] data in
                    let degree: Int = Int((data.currently.temperature - 32) * (5/9)) /// ℉를 ℃로 변경
                    weather.tempature = Int16(degree)
                    weather.type = data.currently.icon
                    weather.weatherId = UUID.init()
                    DispatchQueue.main.sync {
                        self?.temperatureLabel.text = "\(weather.tempature)℃"
                        guard let type = weather.type else { return }
                        self?.weatherImageView.image = UIImage(named: type)
                        self?.weatherLabel.text = WeatherType(rawValue: type)?.summary
                    }
                },
                errorHandler: { [weak self] in
                    self?.showAlert(title: "Error", message: "날씨 정보를 불러올 수 없습니다.")
            })
            entry.weather = weather
            CoreDataManager.shared.save()
        }
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
    }
    
    @IBAction func hideKeyboardDidTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: UITextViewDelegate
extension EntryViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        shouldSaveEntry = true
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
