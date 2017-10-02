//
//  ZJCalenderMonthModel.h
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJCalenderMonthModel : NSObject

/**
 年
 */
@property (nonatomic, assign) NSInteger year;

/**
 月
 */
@property (nonatomic, assign) NSInteger month;

/**
 日模型数组
 */
@property (nonatomic, strong) NSMutableArray *dayModelArray;

/**
 该月第一天是周几
 */
@property (nonatomic, assign) NSInteger firstDayWeek;

/**
 该月多少天
 */
@property (nonatomic, assign) NSInteger dayCount;

@end
