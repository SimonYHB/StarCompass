//
//  CompassGestureView.swift
//  StarSearch
//
//  Created by SimonYHB on 2018/10/6.
//  Copyright © 2018年 yhb. All rights reserved.
//

import UIKit


import UIKit
import SnapKit


class CompassGestureView: UIView,UIGestureRecognizerDelegate {
    //    public var starIndex = BehaviorRelay<[String:String]>.init(value: [:])
    fileprivate var centerPoint = CGPoint.init(x: 157.5, y: 157.5)
    fileprivate var dataSource = [["title":""]]
    fileprivate var radians: CGFloat = 0
    
    fileprivate var orignalPoint = CGPoint.init(x: 0, y: 0)
    
    fileprivate var animationScale: CGFloat = 0
    fileprivate var imageView = UIImageView.init(image:  UIImage.init(named: "zodiac_compass"))
    fileprivate var starIcon = UIImageView.init(image: UIImage.init(named: "zodiac_00"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.isUserInteractionEnabled = true
        self.animationScale = frame.width / (315)
        setupUI()
        bind()
        
        let recognizer1 = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        recognizer1.delegate = self
        recognizer1.minimumNumberOfTouches = 1
        recognizer1.maximumNumberOfTouches = 3
        self.addGestureRecognizer(recognizer1)

        
        
    }

    @objc fileprivate func handlePan(sender: UIPanGestureRecognizer) {
        //translation是变为的点距离
//        let pos = sender.translation(in: self)
        if sender.state == .began {
            self.orignalPoint = sender.location(in: self)
        }
        let endPos = sender.location(in: self)
        rotateTo(orignalPoint:orignalPoint, toPoint:endPos)
        
        if sender.state == .ended {
            let velocity = sender.velocity(in: self)
            self.fixRadians(endPoint: endPos, velocity: velocity)
        }
        orignalPoint = endPos
    }

    
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
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = ((touches as NSSet).anyObject() as! UITouch)
//
//        let orignalPoint = touch.previousLocation(in: self)
//        let movePos = touch.location(in: self)
//        rotateTo(orignalPoint:orignalPoint, toPoint:movePos)
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        //        self.touchesMoved(touches, with: event)
//        self.fixRadians()
//        self.fixStarIndex()
//    }
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
        let newRadians = fabs(radians) + unitRadians * 0.5
        var index = Int((newRadians / unitRadians).truncatingRemainder(dividingBy: 12))
        print("radians\(radians)  index\(index)")
        index = radians < 0 && index != 0 ? 12 - index : index
        print("radians\(radians)  index\(index)")
        self.starIcon.image = UIImage.init(named:  String.init(format: "zodiac_%02d", index))

    }
    /// 移动结束修正角度
    fileprivate func fixRadians(endPoint:CGPoint, velocity: CGPoint) {
//        print(velocity)
        var oldRadians = self.radians
        var endTime: CGFloat = 0.4
        let magnitude = sqrtf(Float(CGFloat((velocity.x * velocity.x)+(velocity.y * velocity.y))));
        let slideFactor = CGFloat(magnitude / 2000)
        if magnitude > 200 {
            endTime = slideFactor > 2 ? 2 : slideFactor
            oldRadians = velocity.x > 0 ? oldRadians - CGFloat(Double.pi) * slideFactor : oldRadians + CGFloat(Double.pi) * slideFactor
        }
        let unitRadians = CGFloat(Double.pi * 2 / 12)
        //取绝对值避免正负数问题(后面再加上正负)
        var newRadians = fabs(oldRadians)
        var quotient = Int(newRadians / unitRadians)
        let remainder = newRadians.truncatingRemainder(dividingBy: unitRadians)
        if remainder > unitRadians * 0.5 {
            quotient += 1
        }
        quotient = oldRadians < 0 ? -quotient : quotient
        newRadians = CGFloat(quotient) * unitRadians
        
        //动画前关闭交互
        self.isUserInteractionEnabled = false
        
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.fromValue = radians
        animation.toValue = newRadians
        animation.duration = CFTimeInterval(endTime);
        animation.fillMode = kCAFillModeBoth;
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        animation.delegate = self
        self.imageView.layer.add(animation, forKey: "rotateAnimation")
        self.radians = newRadians
//        let begin = Int(radians / unitRadians)
        //begin -> quotient

//        UIView.animate(withDuration: TimeInterval(endTime), delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { [weak self] in
//
//            self?.imageView.transform = CGAffineTransform.identity
//            //这种类型转动只能转一圈
////            self?.imageView.transform.rotated(by: disRadians)
////            self?.imageView.transform = CGAffineTransform.identity
////            self?.imageView.transform = CGAffineTransform.init(rotationAngle: oldRadians)
//        }) { [weak self](_) in
//            self?.radians = oldRadians
//        }

        
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
        self.imageView.transform = CGAffineTransform.init(rotationAngle: oldRadians)
        self.radians = oldRadians
        fixStarIndex()
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CompassGestureView: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.imageView.transform = CGAffineTransform.init(rotationAngle: radians)
        //移除动画
        self.imageView.layer.removeAllAnimations()
        //恢复交互
        self.isUserInteractionEnabled = true
        self.fixStarIndex()

    }

}
