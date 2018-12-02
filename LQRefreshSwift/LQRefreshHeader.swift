//
//  LQRefreshHeader.swift
//  LQRefreshSwiftDemo
//
//  Created by hhh on 2018/12/1.
//  Copyright © 2018 LQ. All rights reserved.
//

import UIKit

class LQRefreshHeader: LQRefreshBaseView {
    private var isLQRefreshHead: Bool = false
    let LQEarthHeight = 25
    var animationCount = 0
    
    // 闭包的方式实现回调
    class func headerWithRefreshBlock(block:@escaping LQRefreshingBlock) -> LQRefreshHeader {
        let header = LQRefreshHeader.init()
        header.refreshingBlock = block
        let headerName = self.description()
        if headerName == "LQRefreshSwiftDemo.LQRefreshHeader" {
            header.isLQRefreshHead = true
        }
        return header
    }
    
   //方法的方式实现回调
    class func headerWithRefreshTarget(_ target:Any?,action:Selector) -> LQRefreshHeader {
        let header = LQRefreshHeader.init()
        header.refreshingAction = action
        header.refreshingTarget = target
        let headerName = self.description()
        if headerName == "LQRefreshSwiftDemo.LQRefreshHeader" {
            header.isLQRefreshHead = true
        }
        return header
    }
    
    override func base() {
        super.base()
        var frame = self.frame
        frame.size.height = CGFloat(LQRefreshScrollView.HeaderHeight)
        self.frame = frame
    }
    
    override func updataSubViews() {
        super.updataSubViews()
        if (self.scrollView?.contentInset.top)!  > CGFloat(0) {
            self.startContentInsetTop = (self.scrollView?.contentInset.top)!
        }
        var frame = self.frame
        let y = -self.frame.size.height-self.startContentInsetTop
        frame.origin.y = y
        self.frame = frame
        self.state = LQRefreshState.LQRefreshStatePrepare
        self.startContentOffsetY = self.scrollView?.contentOffset.y ?? 0
        self.addSubview(self.bgImageView)
        self.addSubview(self.imageView)
        self.layer.addSublayer(self.animationLayer)
    }
    
    override func scrollViewContentOffsetDidChange(scrollView: UIScrollView, dictionary: NSDictionary) {
        super.scrollViewContentOffsetDidChange(scrollView: scrollView, dictionary: dictionary)
        let y = -scrollView.contentOffset.y + self.startContentOffsetY;
        self.percent = y / CGFloat(LQRefreshScrollView.HeaderHeight)
        if (self.percent <= 0) {
            self.percent = 0;
        }
        if (self.percent >= 1) {
            self.percent = 1;
        }
        if (!self.isLQRefreshHead) {
            return;
        }
        if (scrollView.isDragging ) {
            if (self.state == LQRefreshState.LQRefreshStateEnd) {
                self.state = LQRefreshState.LQRefreshStatePrepare;
            }
        }
        self.creatPath()
        if (!scrollView.isDragging) {
            if (y >= CGFloat(LQRefreshScrollView.HeaderHeight) && self.state == LQRefreshState.LQRefreshStatePrepare) {
                self.state = LQRefreshState.LQRefreshStateRefreshing;
            }
        }
        
    }
    
    func creatPath() {
        let pathHeight = LQEarthHeight + 10
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: CGFloat(pathHeight)*(2-self.percent)))
        path.addLine(to: CGPoint.init(x: CGFloat(pathHeight), y: CGFloat(pathHeight)*(2-self.percent)))
        path.addLine(to: CGPoint.init(x: CGFloat(pathHeight), y: CGFloat(pathHeight)*(1-self.percent)))
        path.addLine(to: CGPoint.init(x: 0, y: CGFloat(pathHeight)*(1-self.percent)))
        path.close()
        self.maskLayer.path = path.cgPath
    }
    
    //旋转动画
    func rotationAnimation() {
        let rotationAnimaiton = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimaiton.duration = 1.25
        rotationAnimaiton.fromValue = 0
        rotationAnimaiton.toValue = CGFloat(2*Double.pi)
        rotationAnimaiton.repeatCount = MAXFLOAT
        rotationAnimaiton.fillMode = .forwards
        rotationAnimaiton.isRemovedOnCompletion = false
        self.animationLayer.add(rotationAnimaiton, forKey: nil)
        self.strokeEndAnimation()
    }
    
    
    func strokeEndAnimation(){
        let strokeEndAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeEndAnimation.duration = 0.8
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.fillMode = .forwards
        strokeEndAnimation.isRemovedOnCompletion = false
        strokeEndAnimation.delegate = self
        strokeEndAnimation.setValue("strokeEndAnimation", forKey: "stroke")
        self.animationLayer.add(strokeEndAnimation, forKey: "strokeEndAnimation")
    }
    
    func strokeStartAnimation(){
        let strokeStartAnimation = CABasicAnimation.init(keyPath: "strokeStart")
        strokeStartAnimation.duration = 0.8
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.fillMode = .forwards
        strokeStartAnimation.isRemovedOnCompletion = false
        strokeStartAnimation.delegate = self
        strokeStartAnimation.setValue("strokeStartAnimation", forKey: "stroke")
        self.animationLayer.add(strokeStartAnimation, forKey: "strokeStartAnimation")
    }
    
   override var state:LQRefreshState! {
            didSet {
                super.state = state
                if (self.isLQRefreshHead && self.state == LQRefreshState.LQRefreshStateRefreshing) {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.scrollView?.contentInset = UIEdgeInsets.init(top: CGFloat(LQRefreshScrollView.HeaderHeight)+self.startContentInsetTop, left: 0, bottom: 0, right: 0);
                    }) { (finished:Bool) in
                        self.animationLayer.isHidden = false
                        self.rotationAnimation()
                        if (self.refreshingBlock != nil) {
                            self.refreshingBlock!()
                        }
                        
                        if ((self.refreshingTarget as AnyObject).responds(to: self.refreshingAction)) {
                            _ = (self.refreshingTarget as AnyObject).perform(self.refreshingAction!)
                        }
                    }
                }
            }
        
    }
    
    //结束刷新
    override func endRefresh() {
        super.endRefresh()
        UIView.animate(withDuration: 0.25, animations: {
            self.animationLayer.isHidden = true
            self.scrollView?.contentInset = UIEdgeInsets.init(top:self.startContentInsetTop, left: 0, bottom: 0, right: 0);
        }) { (finished:Bool) in
            self.animationLayer.removeAllAnimations()
            self.state = LQRefreshState.LQRefreshStateEnd
        }
    }
    
    //MARK:- lazy
    
    lazy var bgImageView: UIImageView = {
        let bgImageView = UIImageView.init()
        bgImageView.bounds = CGRect.init(x: 0, y: 0, width: CGFloat(LQEarthHeight), height: CGFloat(LQEarthHeight))
        bgImageView.contentMode = UIView.ContentMode.scaleAspectFill
        bgImageView.center = CGPoint.init(x: self.center.x, y: CGFloat(LQRefreshScrollView.HeaderHeight/2))
        let bundle = Bundle.init(path: Bundle.main.path(forResource: "image", ofType: "bundle")!)
        let url = URL.init(fileURLWithPath: (bundle?.path(forResource: "grayEarth", ofType: "png"))!)
        bgImageView.image = UIImage.init(data:try!Data.init(contentsOf: url))
        return bgImageView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.bounds = CGRect.init(x: 0, y: 0, width: CGFloat(LQEarthHeight), height: CGFloat(LQEarthHeight))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.center = CGPoint.init(x: self.center.x, y: CGFloat(LQRefreshScrollView.HeaderHeight/2))
        let bundle = Bundle.init(path: Bundle.main.path(forResource: "image", ofType: "bundle")!)
        let url = URL.init(fileURLWithPath: (bundle?.path(forResource: "earth", ofType: "png"))!)
        imageView.image = UIImage.init(data:try!Data.init(contentsOf: url))
        imageView.layer.mask = self.maskLayer
        return imageView
    }()
    
    lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = CGRect.init(x: 0, y: 0, width: CGFloat(LQEarthHeight), height: CGFloat(LQEarthHeight))
        maskLayer.backgroundColor = UIColor.clear.cgColor
        return maskLayer
    }()
    
    lazy var animationLayer: CAShapeLayer = {
        let w = LQEarthHeight + 15
        let layer = CAShapeLayer.init()
        layer.bounds = CGRect.init(x: 0, y: 0, width: w, height: w)
        layer.position = CGPoint.init(x: self.layer.position.x, y: CGFloat(LQRefreshScrollView.HeaderHeight/2))
        layer.backgroundColor = UIColor.clear.cgColor
        layer.lineWidth = 2
        layer.lineCap = .round
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.init(red: 33/255.0, green: 151/255.0, blue: 216/255.0, alpha: 0.7).cgColor
        layer.isHidden = true
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: w/2, y: w/2),
                                     radius: CGFloat(w/2-2),
                                     startAngle: CGFloat(Double.pi/2),
                                     endAngle:CGFloat(2*Double.pi),
                                     clockwise: true)
        layer.path = path.cgPath
        return layer
    }()
    
}

//MARK:- 实现核心动画的代理方法
extension LQRefreshHeader: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if (self.state == LQRefreshState.LQRefreshStateEnd) {
            self.animationLayer.removeAllAnimations()
            self.animationCount = 0
            return
        }
        let str = anim.value(forKey:"stroke") as! String
        if ( str == "strokeEndAnimation") {
            self.animationLayer.removeAnimation(forKey: "strokeEndAnimation")
            self.strokeStartAnimation()
        }
        else {
            self.animationCount += 1
            let w = self.LQEarthHeight + 15
            let startAngle = CGFloat(Double.pi/2)+CGFloat(3*Double.pi/2)*CGFloat(self.animationCount)
            let endAngle = CGFloat(2*Double.pi)+CGFloat(3*Double.pi/2)*CGFloat(self.animationCount)
            let path = UIBezierPath.init(arcCenter: CGPoint.init(x: w/2, y: w/2),
                                         radius: CGFloat(w/2-2),
                                         startAngle:startAngle,
                                         endAngle:endAngle,
                                         clockwise:true)
            self.animationLayer.path = path.cgPath
            self.animationLayer.removeAnimation(forKey: "strokeStartAnimation")
            self.strokeEndAnimation()
        }
    }
}
