//
//  ZJCalenderMonthModel.m
//  
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "ZJCalenderMonthModel.h"
#import "ZJCalenderDayModel.h"

@implementation ZJCalenderMonthModel

- (void)setDayModelArray:(NSMutableArray *)dayModelArray{
    _dayModelArray = dayModelArray;
    
    _dayCount = _dayModelArray.count;
}

@end
