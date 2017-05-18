//
//  ZJCalenderDateManager.h
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZJCalenderDayModel;

typedef NS_ENUM(NSUInteger, ZJSeletedFailReason) {
    ZJSeletedFailReasonDateDisabled = 0,    //该日期不可选
    ZJSeletedFailReasonIncludeDateDisabled = 1,  //包含不可选日期
    ZJSeletedFailReasonDaysCountLowerThanLimit = 2, //选择天数少于最少天数
    ZJSeletedFailReasonDaysCountHigherThanLimit = 3  //选择天数大于最多天数
};

typedef void(^completeBlock)(NSMutableArray *monthModelArray);
typedef void(^selectedFailBlock)(ZJSeletedFailReason selectedFailReason);
typedef void(^returnBlock)(ZJCalenderDayModel *firstSelectedDayModel, ZJCalenderDayModel *secondSelectedDayModel);
typedef void(^loadCompleteBlock)();

@interface ZJCalenderDateManager : NSObject

/**
 不可选日期数组 @"2015-01-01"格式字符串
 */
@property (nonatomic, strong) NSArray *disabledDaysArray;

/**
 不可选日期数组 NSDate  上面一个参数只会有一个生效, disabledDateArray优先
 */
@property (nonatomic, strong) NSArray *disabledDateArray;

/**
 从今天开始可选, NO则从本月第一天开始可选 默认NO
 */
@property (nonatomic, assign, getter=isSelectedSinceToday) BOOL selectedSinceToday;

/**
 日期下面的统一文字
 */
@property (nonatomic, copy) NSString *text;

/**
 简单模式, 只显示日期 ***此模式需每次推出日历之前设置一次***
 */
@property (nonatomic, assign, getter=isSimpleMode) BOOL simpleMode;

/**
 传入生成模型的月份数量 默认4个月
 */
@property (nonatomic, assign) NSInteger monthCount;

/**
 最少选择天数
 */
@property (nonatomic, assign) NSInteger minSeletedDays;

/**
 最多选择天数
 */
@property (nonatomic, assign) NSInteger maxSeletedDays;

/**
 是否支持多选, 默认支持, 若不支持多选, block回调传选择日期相同
 */
@property (nonatomic, assign, getter=isMultipleEnable) BOOL multipleEnable;

/**
 点击失败回调
 */
@property (nonatomic, copy) selectedFailBlock selectedFail;

/**
 选择完成回调 取消选择两天也会回调 传nil
 */
@property (nonatomic, copy) returnBlock finishSelect;

/**
 加载完成回调
 */
@property (nonatomic, copy) loadCompleteBlock loadComplete;

/**
 是否选中完成
 */
@property (nonatomic, assign, getter=isSelectFinished) BOOL selectFinished;

/**
 第一个选中的天
 */
@property (nonatomic, strong) ZJCalenderDayModel *lastFirstSelectedDayModel;

/**
 第二个选中的天
 */
@property (nonatomic, strong) ZJCalenderDayModel *lastSecondSelectedDayModel;

/**
 单粒快速创建
 */
+ (ZJCalenderDateManager *)sharedManager;

/**
 生成模型数组
 */
- (void)getCalenderDateComplete:(completeBlock)complete;

/**
 是否该显示文本
 */
- (BOOL)showTextWithDate:(NSDate *)date;

/**
 重新获取日历的日期
 */
- (void)refreshDateComplete:(loadCompleteBlock)complete;

/**
 清除选择
 */
- (void)clearSelection;

@end
