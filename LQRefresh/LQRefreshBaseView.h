//
//  LQRefreshBaseView.h
//  LQRefreshDemo
//
//  Created by hongzhiqiang on 2018/11/13.
//  Copyright © 2018 hhh. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN const CGFloat LQRefreshHeaderHeight;
UIKIT_EXTERN NSString *const LQRefreshScrollViewContentOffset;

typedef void(^LQRefreshingBlock)(void);

typedef NS_ENUM(NSUInteger,LQRefreshState){
    LQRefreshStateNormal = 0,
    LQRefreshStatePrepare,
    LQRefreshStateRefreshing,
    LQRefreshStateEnd
};

@interface LQRefreshBaseView : UIView

@property (weak, nonatomic, readonly) UIScrollView *scrollView;

//当前的状态
@property (assign, nonatomic)LQRefreshState state;
//当前的百分比
@property (assign, nonatomic)CGFloat percent;

//开始的偏移量
@property (assign, nonatomic)CGFloat startContentOffsetY;

//开始的insetY
@property (assign, nonatomic)CGFloat startContentInsetTop;

//正在刷新的回调方法
@property (nonatomic, copy) LQRefreshingBlock refreshingBlock;

//回调对象
@property (weak, nonatomic) id refreshingTarget;
//回调方法
@property (assign, nonatomic) SEL refreshingAction;

- (void)refreshTarget:(id)target action:(SEL)action;


- (void)endRefresh NS_REQUIRES_SUPER;
- (void)base NS_REQUIRES_SUPER;
- (void)updateSubViews NS_REQUIRES_SUPER;
- (void)scrollView:(UIScrollView *)scrollView contentOffsetDidChange:(NSDictionary *)dictionary NS_REQUIRES_SUPER;
- (void)scrollView:(UIScrollView *)scrollView contentOffsizeDidChange:(NSDictionary *)dictionary NS_REQUIRES_SUPER;

@end

