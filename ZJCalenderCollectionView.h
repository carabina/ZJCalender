//
//  ZJCalenderCollectionView.h
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCalenderView.h"

@class ZJCalenderDayModel;

@interface ZJCalenderCollectionView : UICollectionView

/**
 传入月份模型数组
 */
@property (nonatomic, strong) NSMutableArray *monthModelArray;

/**
 设置日历模式, 默认为全屏
 */
@property (nonatomic, assign) ZJCalenderMode calenderMode;

/**
 是否加载完成
 */
@property (nonatomic, assign, getter=isLoadComplete) BOOL loadComplete;

@end
