//
//  CompassView.swift
//  StarSearch
//
//  Created by SimonYHB on 2018/10/5.
//  Copyright © 2018年 yhb. All rights reserved.
//

import UIKit
import SnapKit


class CompassView: UIView {
//    public var starIndex = BehaviorRelay<[String:String]>.init(value: [:])
    fileprivate var centerPoint = CGPoint.init(x: 157.5, y: 157.5)
    fileprivate var dataSource = [["title":""]]
    fileprivate var radians: CGFloat = 0
    
    fileprivate var animationScale: CGFloat = 0
    fileprivate var imageView = UIImageView.init(image:  UIImage.init(named: "zodiac_compass"))
    fileprivate var starIcon = UIImageView.init(image: UIImage.init(named: "zodiac_00"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.isUserInteractionEnabled = true
        self.animationScale = frame.width / (315)
        setupUI()
        bind()
        
        
        
    }
    //  坑1
    // 写在layoutSubView里 用UIView的动画options布局子控件 会影响到的自动转动,self?.imageView.transform = CGAffineTransform.init(rotationAngle: newRadians) 方法会重新布局子控件
    public func updateSubView() {
        imageView.frame = CGRect.init(x: 0, y: 0, width: 315 , height: 315 )
        starIcon.frame = CGRect.init(x: 121.5 , y: 235  , width: 72 , height: 72 )
    }
    fileprivate func bind() {
        
    }
    fileprivate func setupUI() {
        self.addSubview(imageView)
        self.addSubview(starIcon)
        imageView.frame = frame
        starIcon.frame = CGRect.init(x: 121.5 * animationScale , y: 235 * animationScale , width: 72 * animationScale , height: 72 * animationScale )
    }
    
    public func rotateSelf() {
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.toValue = Double.pi * 10
        animation.duration = 2.5;
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        self.imageView.layer.add(animation, forKey: "rotateAnimation")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = ((touches as NSSet).anyObject() as! UITouch)
        
        let orignalPoint = touch.previousLocation(in: self)
        let movePos = touch.location(in: self)
        rotateTo(orignalPoint:orignalPoint, toPoint:movePos)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        self.touchesMoved(touches, with: event)
        self.fixRadians()
        self.fixStarIndex()
    }
    fileprivate func radiansToDegrees(_ radians: CGFloat)-> CGFloat {
        return ((radians) * CGFloat(180.0 / Double.pi))
    }
    fileprivate func degreesToRadians(_ angle: CGFloat)-> CGFloat {
        return  ((angle) / 180.0 * CGFloat(Double.pi))
    }
    /// 移动中修正选中星座
    fileprivate func fixStarIndex() {
        //0.5~1.5 展示1
        let unitRadians = CGFloat(Double.pi * 2 / 12)
        let newRadians = radians + unitRadians * 0.5
        let index = Int(fabs(newRadians / unitRadians).truncatingRemainder(dividingBy: 12))
        
        print(String.init(format: "zodiac_%02d", index))
        self.starIcon.image = UIImage.init(named:  String.init(format: "zodiac_%02d", index))
    }
    /// 移动结束修正角度
    fileprivate func fixRadians() {
        let unitRadians = CGFloat(Double.pi * 2 / 12)
        var quotient = Int(radians / unitRadians)
        let remainder = radians.truncatingRemainder(dividingBy: unitRadians)
        if remainder > unitRadians * 0.5 {
            quotient += 1
        }
        let newRadians = CGFloat(quotient) * unitRadians
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.imageView.transform = CGAffineTransform.init(rotationAngle: newRadians)
        }) { [weak self](_) in
            self?.radians = newRadians
        }
        
        
    }
    //
    //    fileprivate func getTrueTransform()
    /// 计算滚动是旋转
    fileprivate func rotateTo(orignalPoint: CGPoint, toPoint: CGPoint) {
        var oldRadians = self.radians
        let xOrignalDistance = fabs(orignalPoint.x-self.imageView.center.x)
        let yOrignalDistance = fabs(orignalPoint.y-self.imageView.center.y)
        var orignalRadians = atan(yOrignalDistance/xOrignalDistance)
        let xDistance = fabs(toPoint.x-self.imageView.center.x)
        let yDistance = fabs(toPoint.y-self.imageView.center.y)
        var radians = atan(yDistance/xDistance)
        
        //判断象限
        radians = toPoint.x < self.imageView.center.x ? CGFloat(Double.pi) - radians : radians
        orignalRadians = orignalPoint.x < self.imageView.center.x ? CGFloat(Double.pi) - orignalRadians : orignalRadians
        let betweenRadians = radians - orignalRadians
        oldRadians += betweenRadians
        
        self.imageView.transform = CGAffineTransform.identity
        self.imageView.transform = CGAffineTransform.init(rotationAngle: oldRadians)
        self.radians = oldRadians
        fixStarIndex()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
