//
//  UIScrollView+LQRefresh.m
//  LQRefreshDemo
//
//  Created by hongzhiqiang on 2018/11/13.
//  Copyright © 2018 hhh. All rights reserved.
//

#import "UIScrollView+LQRefresh.h"
#import "LQRefreshHeader.h"
#import <objc/runtime.h>
@implementation UIScrollView (LQRefresh)


- (void)setLq_header:(LQRefreshHeader *)lq_header {
    if (lq_header != self.lq_header) {
        [self.lq_header removeFromSuperview];
        [self insertSubview:lq_header atIndex:0];
        objc_setAssociatedObject(self, "lq_header", lq_header, OBJC_ASSOCIATION_RETAIN);
    }
}

- (LQRefreshHeader *)lq_header {
   return objc_getAssociatedObject(self, "lq_header");
}


@end
