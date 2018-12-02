//
//  LQRefreshBaseView.swift
//  LQRefreshSwiftDemo
//
//  Created by hhh on 2018/11/28.
//  Copyright © 2018 LQ. All rights reserved.
//

import UIKit

typealias LQRefreshingBlock = () -> ()

 struct LQRefreshScrollView {
    static let contentOffset = "contentOffset"
    static let HeaderHeight = 50
}

enum LQRefreshState:Int {
    case LQRefreshStateNormal = 0
    case LQRefreshStatePrepare = 1
    case LQRefreshStateRefreshing = 2
    case LQRefreshStateEnd = 3
}

class LQRefreshBaseView: UIView {
    
    var state:LQRefreshState!
    var percent:CGFloat = 0
    var scrollView:UIScrollView?
    var refreshingBlock:LQRefreshingBlock?
    var startContentOffsetY:CGFloat = 0
    var startContentInsetTop:CGFloat = 0
    var refreshingTarget:Any?
    var refreshingAction:Selector?
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.base()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func base() {
        self.backgroundColor = .clear
        self.state = .LQRefreshStateNormal
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updataSubViews()
    }
    
    func updataSubViews(){}//子类去实现
    func endRefresh() {}//子类去实现
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview is UIScrollView) {
            self.removeObserver()
            scrollView = newSuperview as? UIScrollView
            scrollView?.alwaysBounceVertical = true
            var frame = self.frame
            let w = newSuperview?.frame.size.width
            frame.size.width = w!
            if w == 0 {
               frame.size.width = UIScreen.main.bounds.size.width
            }
            self.frame = frame
            self.addObserver()
        }
    }
    
   private func addObserver() {
        let options = NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue
        self.scrollView?.addObserver(self, forKeyPath: LQRefreshScrollView.contentOffset, options: NSKeyValueObservingOptions(rawValue: options), context: nil)
    }
    
   private func removeObserver() {
        self.scrollView?.removeObserver(self, forKeyPath: LQRefreshScrollView.contentOffset)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == LQRefreshScrollView.contentOffset {
            self.scrollViewContentOffsetDidChange(scrollView: scrollView!, dictionary: change! as NSDictionary)
        }
    }
    
    func scrollViewContentOffsetDidChange(scrollView:UIScrollView,dictionary:NSDictionary)  {}//子类实现
}
