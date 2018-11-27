//
//  LQRefreshHeader.h
//  LQRefreshDemo
//
//  Created by hongzhiqiang on 2018/11/13.
//  Copyright © 2018 hhh. All rights reserved.
//

#import "LQRefreshBaseView.h"

@interface LQRefreshHeader : LQRefreshBaseView

+ (instancetype)headerWithRefreshBlock:(LQRefreshingBlock)block;
+ (instancetype)headerWithRefreshTarge:(id)target refreshAction:(SEL)action;



@end


