//
//  ViewController.swift
//  StarSearch
//
//  Created by SimonYHB on 2018/10/5.
//  Copyright © 2018年 yhb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate var compassView = CompassGestureView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    

    fileprivate func setupUI() {
        view.backgroundColor = UIColor.blue
        view.addSubview(compassView)
        UIView.setAnimationsEnabled(true)
        let rect = CGRect.init(x: 0, y: 0, width: 315 , height: 315 )
        let center = self.view.center
//        self.compassView.updateSubView()
//        self.compassView.frame = rect
        compassView.center = center
        self.compassView.isUserInteractionEnabled = true
        
        self.compassView.isUserInteractionEnabled = false
        
        
        self.compassView.rotateSelf()
        
        UIView.animate(withDuration: 1.5, animations: { [weak self] in
            self?.compassView.frame = rect
            self?.compassView.center = center
            self?.compassView.updateSubView()
        }) { [weak self] (_) in
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.compassView.center = CGPoint.init(x: center.x, y: 0)
                }, completion: { [weak self] (_) in
                    self?.compassView.isUserInteractionEnabled = true
            })

        }

        
    }


}



