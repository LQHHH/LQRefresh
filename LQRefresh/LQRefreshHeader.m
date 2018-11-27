//
//  LQRefreshHeader.m
//  LQRefreshDemo
//
//  Created by hongzhiqiang on 2018/11/13.
//  Copyright © 2018 hhh. All rights reserved.
//

#import "LQRefreshHeader.h"
#import <objc/message.h>
CGFloat const LQEarthHeight = 25;

@interface LQRefreshHeader () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *animationLayer;
@property (nonatomic, assign) NSInteger animationCount;
@property (nonatomic, assign) BOOL isLQRefreshHead;

@end

@implementation LQRefreshHeader

+ (instancetype)headerWithRefreshBlock:(LQRefreshingBlock)block {
    LQRefreshHeader *header = [[LQRefreshHeader alloc] init];
    header.refreshingBlock = block;
    NSString *headerName = NSStringFromClass(self);
    if ([headerName isEqualToString:@"LQRefreshHeader"]) {
        header.isLQRefreshHead = YES;
    }
    return header;
}

+ (instancetype)headerWithRefreshTarge:(id)target refreshAction:(SEL)action {
    LQRefreshHeader *header = [[LQRefreshHeader alloc] init];
    [header refreshTarget:target action:action];
    NSString *headerName = NSStringFromClass(self);
    if ([headerName isEqualToString:@"LQRefreshHeader"]) {
        header.isLQRefreshHead = YES;
    }
    return header;
}

- (void)base {
    [super base];
    CGRect frame = self.frame;
    frame.size.height = LQRefreshHeaderHeight;
    self.frame = frame;
}

- (void)updateSubViews {
    [super updateSubViews];
    self.startContentInsetTop = self.scrollView.contentInset.top >0?self.scrollView.contentInset.top:0;
    CGRect frame = self.frame;
    frame.origin.y = -self.frame.size.height-self.startContentInsetTop;
    self.frame = frame;
    self.state = LQRefreshStatePrepare;
    self.startContentOffsetY = self.scrollView.contentOffset.y;
    
}

- (void)scrollView:(UIScrollView *)scrollView contentOffsetDidChange:(NSDictionary *)dictionary {
    [super scrollView:scrollView contentOffsetDidChange:dictionary];
    CGFloat y = -scrollView.contentOffset.y + self.startContentOffsetY;
    self.percent = y / LQRefreshHeaderHeight;
    if (self.percent <= 0) {
        self.percent = 0;
    }
    if (self.percent >= 1) {
        self.percent = 1;
    }
    if (!self.isLQRefreshHead) {
        return;
    }
    [self bgImageView];
    [self imageView];
    [self animationLayer];
    if (scrollView.isDragging ) {
        if (self.state == LQRefreshStateEnd) {
            self.state = LQRefreshStatePrepare;
        }
    }
    [self creatPath];
    if (!scrollView.isDragging) {
        if (y >= LQRefreshHeaderHeight && self.state == LQRefreshStatePrepare) {
            self.state = LQRefreshStateRefreshing;
        }
    }
}

- (void)setState:(LQRefreshState)state {
    [super setState:state];
    if (self.isLQRefreshHead && self.state == LQRefreshStateRefreshing) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.scrollView setContentInset:UIEdgeInsetsMake(LQRefreshHeaderHeight+self.startContentInsetTop, 0, 0, 0)];
        } completion:^(BOOL finished) {
            self.animationLayer.hidden = NO;
            [self rotationAnimation];
            if (self.refreshingBlock) {
                self.refreshingBlock();
            }
            if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
                ((void (*)(id,SEL))objc_msgSend)(self.refreshingTarget,self.refreshingAction);
            }
        }];
    }
}

- (void)creatPath {
    CGFloat pathHeight = LQEarthHeight+10;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, pathHeight*(2-self.percent))];
    [path addLineToPoint:CGPointMake(pathHeight, pathHeight*(2-self.percent))];
    [path addLineToPoint:CGPointMake(pathHeight, pathHeight*(1-self.percent))];
    [path addLineToPoint:CGPointMake(0, pathHeight*(1-self.percent))];
    [path closePath];
    self.maskLayer.path = path.CGPath;
}

- (void)rotationAnimation {
    CABasicAnimation *rotationAnimaiton = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimaiton.duration = 1.25;
    rotationAnimaiton.fromValue = @0;
    rotationAnimaiton.toValue = @(2*M_PI);
    rotationAnimaiton.repeatCount = MAXFLOAT;
    rotationAnimaiton.fillMode = kCAFillModeForwards;
    rotationAnimaiton.removedOnCompletion = NO;
    [self.animationLayer addAnimation:rotationAnimaiton forKey:nil];
    [self strokeAnimation];
}

- (void)strokeAnimation {
    CABasicAnimation *strokeAnimaiton = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimaiton.duration = 0.8;
    strokeAnimaiton.fromValue = @0;
    strokeAnimaiton.toValue = @1;
    strokeAnimaiton.fillMode = kCAFillModeForwards;
    strokeAnimaiton.removedOnCompletion = NO;
    strokeAnimaiton.delegate = self;
    [strokeAnimaiton setValue:@"strokeAnimation" forKey:@"stroke"];
    [self.animationLayer addAnimation:strokeAnimaiton forKey:@"strokeAnimation"];
}

- (void)stroke1Animation {
    CABasicAnimation *stroke1Animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    stroke1Animation.duration = 1;
    stroke1Animation.fromValue = @0;
    stroke1Animation.toValue = @1;
    stroke1Animation.fillMode = kCAFillModeForwards;
    stroke1Animation.removedOnCompletion = NO;
    stroke1Animation.delegate = self;
    [stroke1Animation setValue:@"stroke1Animation" forKey:@"stroke"];
    [self.animationLayer addAnimation:stroke1Animation forKey:@"stroke1Animation"];
}

#pragma mark - caanimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.state == LQRefreshStateEnd) {
        [self.animationLayer removeAllAnimations];
        _animationCount = 0;
        return;
    }
    if ([[anim valueForKey:@"stroke"] isEqualToString:@"strokeAnimation"]) {
        [self.animationLayer removeAnimationForKey:@"strokeAnimation"];
        [self stroke1Animation];
    }
    else {
        _animationCount++;
        CGFloat w = LQEarthHeight + 15;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w/2, w/2)
                                                            radius:w/2-2
                                                        startAngle:M_PI_2+(3*M_PI_2)*_animationCount
                                                          endAngle:2*M_PI+(3*M_PI_2)*_animationCount
                                                         clockwise:YES];
        self.animationLayer.path = path.CGPath;
        [self.animationLayer removeAnimationForKey:@"stroke1Animation"];
        [self strokeAnimation];
    }
}

- (void)endRefresh {
    [super endRefresh];
    [UIView animateWithDuration:0.25 animations:^{
        self.animationLayer.hidden = YES;
        self.scrollView.contentInset = UIEdgeInsetsMake(self.startContentInsetTop, 0, 0, 0);
    } completion:^(BOOL finished) {
         [self.animationLayer removeAllAnimations];
         self.state = LQRefreshStateEnd;
    }];
}

#pragma mark - lazy

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.bounds = CGRectMake(0, 0, LQEarthHeight, LQEarthHeight);
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.center = self.center;
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"bundle"]];
        _bgImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"grayEarth" ofType:@"png"]]];
        [self addSubview:_bgImageView];
        
    }
    return _bgImageView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.bounds = CGRectMake(0, 0, LQEarthHeight, LQEarthHeight);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.center = self.center;
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"bundle"]];
        _imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"earth" ofType:@"png"]]];
        _imageView.layer.mask = self.maskLayer;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = CGRectMake(0, 0, LQEarthHeight, LQEarthHeight);
        _maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
    
    return _maskLayer;
}

- (CAShapeLayer *)animationLayer {
    if (!_animationLayer) {
        CGFloat w = LQEarthHeight + 15;
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.bounds = CGRectMake(0, 0, w, w);
        layer.position = self.layer.position;
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.lineWidth = 2;
        layer.lineCap = kCALineCapRound;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor colorWithRed:33/255.0 green:151/255.0 blue:216/255.0 alpha:0.7].CGColor;
        layer.hidden = YES;
        [self.layer addSublayer:layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w/2, w/2)
                                                            radius:w/2-2
                                                        startAngle:M_PI_2
                                                          endAngle:2*M_PI
                                                         clockwise:YES];
        layer.path = path.CGPath;
        _animationLayer = layer;

    }
    return _animationLayer;
}

@end
