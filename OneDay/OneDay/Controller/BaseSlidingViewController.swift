//
//  BaseSlidingViewController.swift
//  OneDay
//
//  Created by 정화 on 11/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class BaseSlidingViewController: UIViewController {
    fileprivate var isMenuOpened = false
    fileprivate var isStatusBarHidden = false
    
    fileprivate var baseMainViewLeftConstraint: NSLayoutConstraint!
    fileprivate var baseMainViewRightConstraint: NSLayoutConstraint!
    fileprivate let sideWidth = UIScreen.main.bounds.width*0.75

    var statusBarAnimator = UIViewPropertyAnimator()
    
    let baseMainView: UIView = {
        let view = UIView()
        view.backgroundColor = .doBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let baseSideView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let blurCoverView: UIView = {
        let blur = UIVisualEffectView()
        blur.backgroundColor = UIColor(white: 0, alpha: 0.2)
        blur.alpha = 0
        blur.effect = UIBlurEffect(style: .dark)
        blur.translatesAutoresizingMaskIntoConstraints = false
        return blur
    }()
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .doBlue
        setupViews()
        setupViewControllers()
        setupGesture()
    }
    
    fileprivate func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss))
        blurCoverView.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func handleTapDismiss() {
        isMenuOpened = false
        baseMainViewLeftConstraint.constant = 0
        baseMainViewRightConstraint.constant = 0
        performAnimation()
        
        isStatusBarHidden = false
        UIView.animate(withDuration: 0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        var distance = translation.x
        
        distance = isMenuOpened ? distance+sideWidth : distance
        distance = min(sideWidth, distance)
        distance = max(0, distance)
        
        let progress = distance/sideWidth // 0.0 ~ 1
        baseMainViewLeftConstraint.constant = distance
        baseMainViewRightConstraint.constant = distance
        blurCoverView.alpha = progress
        
        switch gesture.state {
        case .began:
            isStatusBarHidden = !isStatusBarHidden
            
            statusBarAnimator = UIViewPropertyAnimator(
                duration: 0.1,
                curve: .easeOut,
                animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
            statusBarAnimator.startAnimation()
            statusBarAnimator.pauseAnimation()
            
        case .changed:
            statusBarAnimator.fractionComplete = isStatusBarHidden ? progress : 1-progress
            
        case .ended:
            statusBarAnimator.stopAnimation(true)
            handleEnded(gesture: gesture)
        default:
            ()
        }
    }
    
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let threshold: CGFloat = 500
        
        if isMenuOpened {
            if abs(velocity.x) > threshold || abs(translation.x) > sideWidth/2 {
                closeMenu()
            } else {
                openMenu()
            }
        } else {
            if velocity.x > threshold || translation.x > sideWidth/2 {
                openMenu()
            } else {
                closeMenu()
            }
        }
    }
    
    fileprivate func openMenu() {
        isStatusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
        isStatusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        isMenuOpened = true
        baseMainViewLeftConstraint.constant = sideWidth
        baseMainViewRightConstraint.constant = sideWidth
        performAnimation()
        
    }
    
    fileprivate func closeMenu() {
        isStatusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        isStatusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
        
        isMenuOpened = false
        baseMainViewLeftConstraint.constant = 0
        baseMainViewRightConstraint.constant = 0
        performAnimation()
    }
    
    fileprivate func performAnimation() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.blurCoverView.alpha = self.isMenuOpened ? 1 : 0
                self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    fileprivate func setupViews() {
        view.addSubview(baseMainView)
        baseMainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        baseMainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        baseMainViewRightConstraint = baseMainView.rightAnchor.constraint(
            equalTo: view.rightAnchor)
        baseMainViewRightConstraint.isActive = true
        
        baseMainViewLeftConstraint = baseMainView.leftAnchor.constraint(equalTo: view.leftAnchor)
        baseMainViewLeftConstraint.isActive = true
        
        view.addSubview(baseSideView)
        baseSideView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        baseSideView.rightAnchor.constraint(
            equalTo: baseMainView.safeAreaLayoutGuide.leftAnchor).isActive = true
        baseSideView.bottomAnchor.constraint(equalTo: baseMainView.bottomAnchor).isActive = true
        baseSideView.widthAnchor.constraint(equalToConstant: sideWidth).isActive = true
    }
    
    fileprivate func setupViewControllers() {
        guard let mainViewController: MainTabBarViewController =
            storyboard?.instantiateViewController(
                withIdentifier: "tabMain") as? MainTabBarViewController
        else {
            return
        }
        
        let sideViewController = SideMenuViewController()
        
        let mainView = mainViewController.view!
        let sideView = sideViewController.view!
        
        mainView.backgroundColor = .white
        mainView.translatesAutoresizingMaskIntoConstraints = false
        sideView.translatesAutoresizingMaskIntoConstraints = false
        
        baseMainView.addSubview(mainView)
        mainView.leftAnchor.constraint(equalTo: baseMainView.leftAnchor).isActive = true
        mainView.topAnchor.constraint(
            equalTo: baseMainView.topAnchor,
            constant: 20).isActive = true
        mainView.rightAnchor.constraint(equalTo: baseMainView.rightAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: baseMainView.bottomAnchor).isActive = true
        
        baseMainView.addSubview(blurCoverView)
        blurCoverView.leftAnchor.constraint(equalTo: baseMainView.leftAnchor).isActive = true
        blurCoverView.topAnchor.constraint(equalTo: baseMainView.topAnchor).isActive = true
        blurCoverView.rightAnchor.constraint(equalTo: baseMainView.rightAnchor).isActive = true
        blurCoverView.bottomAnchor.constraint(equalTo: baseMainView.bottomAnchor).isActive = true
        
        let height = UIScreen.main.bounds.height
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 6, height: height))
        blurCoverView.layer.shadowColor = UIColor.black.cgColor
        blurCoverView.layer.shadowOpacity = 1
        blurCoverView.layer.shadowOffset = CGSize.zero
        blurCoverView.layer.shadowPath = shadowPath.cgPath
        blurCoverView.layer.masksToBounds = true

        baseSideView.addSubview(sideView)
        sideView.leftAnchor.constraint(equalTo: baseSideView.leftAnchor).isActive = true
        sideView.topAnchor.constraint(
            equalTo: baseSideView.topAnchor,
            constant: 20).isActive = true
        sideView.rightAnchor.constraint(equalTo: baseSideView.rightAnchor).isActive = true
        sideView.bottomAnchor.constraint(equalTo: baseSideView.bottomAnchor).isActive = true
        
        addChild(mainViewController)
        addChild(sideViewController)
    }
}
