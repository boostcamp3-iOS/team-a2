//
//  EditJournalViewController.swift
//  OneDay
//
//  Created by juhee on 19/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class EditJournalViewController: UIViewController {

    @IBOutlet var journalsTableView: UITableView!
    
    var journals: [Journal] = CoreDataManager.shared.journalsWithoutDefault
    
    var cellSnapShot: UIView!
    var initialIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(gestureRecognizer:)))
        journalsTableView.addGestureRecognizer(longpress)
    }
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        guard let longpress = gestureRecognizer as? UILongPressGestureRecognizer else { return }
        let locationInView = longpress.location(in: journalsTableView)
        switch longpress.state {
        case .began:
            guard let indexPath = journalsTableView.indexPathForRow(at: locationInView),
                let cell = journalsTableView.cellForRow(at: indexPath) else { return }
            initialIndexPath = indexPath
            cellSnapShot = snapshopOfCell(inputView: cell)
            cellSnapShot.center = cell.center
            cellSnapShot.alpha = 0
            journalsTableView.addSubview(cellSnapShot!)
            UIView.animate(withDuration: 0.25, animations: {
                self.cellSnapShot.center.y = locationInView.y
                self.cellSnapShot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.cellSnapShot.alpha = 0.98
                cell.alpha = 0
            }, completion: { (finished) -> Void in
                cell.isHidden = finished
            })
        case .changed:
            cellSnapShot?.center.y = locationInView.y
            guard let indexPath = journalsTableView.indexPathForRow(at: locationInView),
                let initialIndexPath = initialIndexPath, indexPath != initialIndexPath else { return }
            if indexPath.section == initialIndexPath.section {
                journals.swapAt(indexPath.row, initialIndexPath.row)
                journalsTableView.moveRow(at: initialIndexPath, to: indexPath)
                self.initialIndexPath = indexPath
            }
        case .ended:
            didLongPressEnded(indexPath: journalsTableView.indexPathForRow(at: locationInView))
        default:
            ()
        }
    }
    
    // Long Press 가 끝나면 snapshot 을 없애주고 cell을 다시 보여줍니다.
    func didLongPressEnded(indexPath: IndexPath?) {
        var cell: UITableViewCell!
        if let indexPath = indexPath {
            cell = journalsTableView.cellForRow(at: indexPath)
        } else {
            cell = journalsTableView.cellForRow(at: initialIndexPath)
        }
        guard cell != nil else { preconditionFailure() }
        cell.isHidden = false
        cell.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.cellSnapShot?.center = cell.center
            self.cellSnapShot?.transform = .identity
            self.cellSnapShot?.alpha = 0
            cell.alpha = 1
        }, completion: { (finished) -> Void in
            if finished {
                self.initialIndexPath = nil
                self.cellSnapShot?.removeFromSuperview()
                self.cellSnapShot = nil
            }
        })
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0)
        cellSnapshot.layer.shadowRadius = 5
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        for index in 0..<journals.count {
            let journal = journals[index]
            journal.index = (index + 1) as NSNumber
        }
        
        CoreDataManager.shared.save()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension EditJournalViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return journals.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editable_journal", for: indexPath)
            let journal = journals[indexPath.row]
            cell.textLabel?.text = journal.title
            cell.detailTextLabel?.text = "\(journal.entries?.count ?? 0)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "add_new_journal", for: indexPath)
            cell.textLabel?.text = "새 저널 추가"
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
}

extension EditJournalViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var alertController: UIAlertController!
        if indexPath.section == 1 {
            alertController = UIAlertController(title: "저널 추가", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "저널 이름"
            }
            let confirmAction = UIAlertAction(title: "저널 추가", style: .default) { [weak self, weak alertController] _ in
                guard let alertController = alertController,
                    let journalTitle = alertController.textFields?.first?.text else { return }
                guard let self = self else { return }
                let journal = CoreDataManager.shared.insertJournal(journalTitle, index: indexPath.row + 1)
                self.journals.append(journal)
                tableView.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        } else {
            let journal = journals[indexPath.row]
            alertController = UIAlertController(title: "저널 이름 변경", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = journal.title ?? "새로운 저널 이름"
            }
            let confirmAction = UIAlertAction(title: "저장", style: .default) { [weak self, weak alertController] _ in
                guard let alertController = alertController,
                    let journalTitle = alertController.textFields?.first?.text else { return }
                guard let self = self else { return }
                let journal = CoreDataManager.shared.journal(id: journal.journalId)
                journal.title = journalTitle
                CoreDataManager.shared.save()
                self.journals[indexPath.row] = journal
                tableView.reloadData()
            }
            alertController.addAction(confirmAction)
        }
        present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if indexPath.section == 0 {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let journal = journals[indexPath.row]
            let alert = UIAlertController(title: "\(journal.title ?? "") 저널을 삭제하시겠습니까?",
                message: "\(journal.entries?.count ?? 0)개의 기록이 사라집니다!",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: {[weak self]_ in
                self?.journals.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                CoreDataManager.shared.remove(journal: journal)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
