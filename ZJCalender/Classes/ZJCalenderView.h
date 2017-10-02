//
//  ZJCalenderView.h
//
//
//  Created by 张骏 on 17/3/28.
//  Copyright © 2017年 Zj. All rights reserved.
//  直接使用setframe只能修改y值

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZJCalenderMode) {
    ZJCalenderModeFullScreen = 0,
    ZJCalenderModePartScreen = 1
};

@interface ZJCalenderView : UIView

/**
 是否可选
 */
@property (nonatomic, assign, getter=isSelectedEnable) BOOL selectedEnable;

/**
 实例化方法, ZJCalenderModePartScreen模式无法更改size
 */
- (instancetype)initWithFrame:(CGRect)frame calenderMode:(ZJCalenderMode)calenderMode;

/**
 刷新数据
 */
- (void)reloadData;

@end
