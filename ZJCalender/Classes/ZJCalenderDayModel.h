//
//  ZJCalenderDayModel.h
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZJCalenderMonthModel;

typedef NS_ENUM(NSUInteger, ZJCalenderSelectedMode) {
    ZJCalenderSelectedModeNone = 0,
    ZJCalenderSelectedModeFirst = 1,
    ZJCalenderSelectedModeSecond = 2,
};

@interface ZJCalenderDayModel : NSObject

/**
 天
 */
@property (nonatomic, assign) NSInteger day;

/**
 节日
 */
@property (nonatomic, assign) NSString *holiday;

/**
 月
 */
@property (nonatomic, assign) NSInteger month;

/**
 年
 */
@property (nonatomic, assign) NSInteger year;

/**
 时间
 */
@property (nonatomic, strong) NSDate *date;

/**
 该天是周几
 */
@property (nonatomic, assign) NSInteger week;

/**
 该天描述文字 // 注意选中后会变成选中文字(ZJCalenderFirstSelectedText, ZJCalenderSecondSelectedText) 此时若要取则取orginText
 */
@property (nonatomic, copy) NSString *text;

/**
 该天原本描述文字, 在选中后获取原本文字时使用
 */
@property (nonatomic, copy, readonly) NSString *orginText;

/**
 这一天属于的月份模型
 */
@property (nonatomic, weak) ZJCalenderMonthModel *monthModel;

/**
 是否被选中
 */
@property (nonatomic, assign) ZJCalenderSelectedMode selectedMode;

/**
 是否可选
 */
@property (nonatomic, assign, getter=isSelectedEnable) BOOL selectedEnable;

/**
 是否处于被包括状态
 */
@property (nonatomic, assign, getter=isIncluded) BOOL included;

/**
 该模型处在collection的indexPath
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
