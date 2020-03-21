//
//  LWPhotoBrowserController.h
//  TransitionDemo
//
//  Created by weil on 2018/5/7.
//  Copyright © 2018年 weil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWPhotoBrowserInteractiveTransition.h"

@class LWPhotoModel;
@interface LWPhotoBrowserController : UIViewController
@property (nonatomic,strong) LWPhotoBrowserInteractiveTransition *animatedTransition;
@property (nonatomic,strong) NSArray<LWPhotoModel*> *photosArray;
@property (nonatomic, copy) void (^scrollToIndex)(NSUInteger index);
//是否显示页数指示器，默认不显示
@property (nonatomic, assign) BOOL showPageIndicator;
- (void) reload;
@end
