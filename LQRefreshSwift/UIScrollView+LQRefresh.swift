//
//  UIScrollView+LQRefresh.swift
//  LQRefreshSwiftDemo
//
//  Created by hhh on 2018/11/28.
//  Copyright © 2018 LQ. All rights reserved.
//

import UIKit

var LQRefreshHeaderKey = 110

extension UIScrollView {
    var lq_header: LQRefreshHeader? {
        set (newValue) {
            if newValue != nil {
                self.lq_header?.removeFromSuperview()
                self.insertSubview(newValue!, at: 0)
                objc_setAssociatedObject(self, &LQRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            return objc_getAssociatedObject(self, &LQRefreshHeaderKey) as? LQRefreshHeader
        }
    }
    
}
