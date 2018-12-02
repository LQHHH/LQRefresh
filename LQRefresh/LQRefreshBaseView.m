//
//  LQRefreshBaseView.m
//  LQRefreshDemo
//
//  Created by hongzhiqiang on 2018/11/13.
//  Copyright © 2018 hhh. All rights reserved.
//

#import "LQRefreshBaseView.h"

CGFloat const  LQRefreshHeaderHeight = 50;
NSString *const LQRefreshScrollViewContentOffset = @"contentOffset";

@implementation LQRefreshBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self base];
    }
    return self;
}

- (void)base {
    self.backgroundColor = [UIColor clearColor];
    self.state = LQRefreshStateNormal;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSubViews];
}

- (void)updateSubViews {};
- (void)endRefresh {};

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
         [self removeObserver];
        _scrollView = (UIScrollView *)newSuperview;
        _scrollView.alwaysBounceVertical = YES;
        CGRect frame = self.frame;
        frame.size.width = newSuperview.frame.size.width>0? :[UIScreen mainScreen].bounds.size.width;
        self.frame = frame;
        [self addObserver];
    }
}

- (void)addObserver {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:LQRefreshScrollViewContentOffset options:options context:nil];
}

- (void)removeObserver {
    [self.superview removeObserver:self forKeyPath:LQRefreshScrollViewContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:LQRefreshScrollViewContentOffset]) {
        [self scrollView:self.scrollView contentOffsetDidChange:change];
    }
}

- (void)scrollView:(UIScrollView *)scrollView contentOffsetDidChange:(NSDictionary *)dictionary {}

- (void)refreshTarget:(id)target action:(SEL)action {
    self.refreshingTarget = target;
    self.refreshingAction = action;
}

- (void)setState:(LQRefreshState)state {
    _state = state;
}

- (void)setPercent:(CGFloat)percent {
    _percent = percent;
}

@end
