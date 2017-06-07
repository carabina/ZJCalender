//
//  ZJCalenderDateManager.m
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "ZJCalenderDateManager.h"
#import "ZJCalenderMonthModel.h"
#import "ZJCalenderDayModel.h"
#import "ZJCalenderConst.h"

@interface ZJCalenderDateManager()
@property (nonatomic, strong) NSMutableArray *monthModelArry;
@property (nonatomic, assign, getter=isRefresh) BOOL refresh;

@end

@implementation ZJCalenderDateManager

static ZJCalenderDateManager *sharedManager = nil;

#pragma mark ---public---
- (void)getCalenderDateComplete:(completeBlock)complete{
    
    if (!self.isRefresh && _monthModelArry.count) {
        if (complete) {
            complete(_monthModelArry);
        }
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSMutableArray *monthModelArray = [NSMutableArray array];
        
        NSDate *startDate = [NSDate date];
        NSInteger dayCount = [self totaldaysInMonth:startDate];  //月份的所有天数
        NSInteger firstday = [self firstWeekdayInThisMonth:startDate]; // 本月的第一天是周几
        NSInteger year = [self year:startDate]; //年份
        NSInteger month = [self month:startDate];
        
        for (NSInteger y = year; y <= year + 1; y++) {  //遍历年
            
            for (NSInteger m = month; m <= 12; m++) {  //遍历月
                
                ZJCalenderMonthModel *monthModel = [[ZJCalenderMonthModel alloc] init];
                monthModel.year = y;
                monthModel.month = m;
                monthModel.firstDayWeek = firstday;
                
                NSMutableArray *dayModelArray = [NSMutableArray array];
                for (NSInteger d = 1; d <= dayCount; d++) { //遍历日
            
                    NSString *dateStr = [NSString stringWithFormat:@"%li-%02li-%02li", y, m, d];
                    NSDate *date = [self dateFromString:dateStr];
                    
                    ZJCalenderDayModel *dayModel = [[ZJCalenderDayModel alloc] init];
                    dayModel.day = d;
                    dayModel.week = (firstday + d - 1) % 7;
                    dayModel.month = m;
                    dayModel.year = y;
                    dayModel.date = date;
                    dayModel.holiday = [self getHolidays:date];
                    dayModel.text = _text;
                    dayModel.monthModel = monthModel;
                    dayModel.selectedEnable = YES;
                    
                    if (self.isSelectedSinceToday) {
                        dayModel.selectedEnable = ![self isDateInPast:dayModel.date];
                    }
                    
                    if (_disabledDateArray.count && dayModel.selectedEnable) {
                        [_disabledDateArray enumerateObjectsUsingBlock:^(NSDate *diabledDate, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                            NSComparisonResult disableResult = [dayModel.date compare:diabledDate];
                            dayModel.selectedEnable = disableResult == NSOrderedSame || !dayModel.selectedEnable ? NO : YES;
                            *stop = !dayModel.selectedEnable;
                        }];
                    }
                    
                    [dayModelArray addObject:dayModel];
                }
                monthModel.dayModelArray = dayModelArray;
                
                startDate = [self nextMonth:startDate];
                dayCount = [self totaldaysInMonth:startDate];
                firstday = [self firstWeekdayInThisMonth:startDate];
                
                [monthModelArray addObject:monthModel];
                if (monthModelArray.count == _monthCount) break;
            }
            month = 1;
            if (monthModelArray.count == _monthCount) break;
        }
        
        if (_monthModelArry) {
            [_monthModelArry removeAllObjects];
            [_monthModelArry addObjectsFromArray:monthModelArray];
        } else {
            _monthModelArry = monthModelArray;
        }
        
        if (complete) {
            complete(monthModelArray);
        }
    });
}


- (void)setDisabledDaysArray:(NSArray *)disabledDaysArray{
    _disabledDaysArray = disabledDaysArray;
    
    NSMutableArray *disabledDateArray = [NSMutableArray array];
    [disabledDaysArray enumerateObjectsUsingBlock:^(NSString *dayStr, NSUInteger idx, BOOL * _Nonnull stop) {
        [disabledDateArray addObject:[self dateFromString:dayStr]];
    }];
    
    _disabledDateArray = disabledDateArray.copy;
}


- (BOOL)showTextWithDate:(NSDate *)date{
    return self.isSelectedSinceToday ? ![self isDateInPast:date] : YES;
}


- (void)refreshDateComplete:(loadCompleteBlock)complete{
    self.refresh = YES;
    [self getCalenderDateComplete:^(NSMutableArray *monthModelArray) {
        self.refresh = NO;
        if (complete) {
            complete();
        }
    }];
}


- (void)clearSelection{
    
    if (self.simpleMode) return;
    self.lastFirstSelectedDayModel = nil;
    self.lastSecondSelectedDayModel = nil;
    self.selectFinished = NO;
    [_monthModelArry enumerateObjectsUsingBlock:^(ZJCalenderMonthModel *monthModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [monthModel.dayModelArray enumerateObjectsUsingBlock:^(ZJCalenderDayModel *dayModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (dayModel.selectedMode == ZJCalenderSelectedModeFirst) {
                self.lastFirstSelectedDayModel = dayModel;
                dayModel.selectedMode = ZJCalenderSelectedModeNone;
            } else if (dayModel.isIncluded) {
                dayModel.included = NO;
            } else if (dayModel.selectedMode == ZJCalenderSelectedModeSecond) {
                self.lastSecondSelectedDayModel = dayModel;
                dayModel.selectedMode = ZJCalenderSelectedModeNone;
            }
            
            *stop = self.lastFirstSelectedDayModel && self.lastSecondSelectedDayModel;
        }];
    }];
}


- (void)setSimpleMode:(BOOL)simpleMode{
    _simpleMode = simpleMode;
    
    if (simpleMode) {
        self.disabledDateArray = nil;
        self.disabledDaysArray = nil;
        self.lastFirstSelectedDayModel = nil;
        self.lastSecondSelectedDayModel = nil;
        self.maxSeletedDays = 10000;
        self.minSeletedDays = 0;
        self.text = nil;
        
        //[self refreshDateComplete:nil];
    }
}


#pragma mark ---singleton---
+ (ZJCalenderDateManager *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
            
            //默认参数
            sharedManager.monthCount = 4;
            sharedManager.multipleEnable = YES;
            sharedManager.selectedSinceToday = NO;
            sharedManager.simpleMode = NO;
            sharedManager.maxSeletedDays = 10000;
            sharedManager.minSeletedDays = 0;
        }
    });
    return sharedManager;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
        }
    });
    return sharedManager;
}


- (id)copy{
    return self;
}


- (id)mutableCopy{
    return self;
}


#pragma mark ---private---
/**
 获取天
 */
- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay) fromDate:date];
    return [components day];
}

/**
 获取月
 */
- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth) fromDate:date];
    return [components month];
}

/**
 获取年
 */
- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear) fromDate:date];
    return [components year];
}

/**
 获取某个月的第一天是周几
 */
- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

/**
 获取某个月的所有总天数
 */
- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInOfMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInOfMonth.length;
}

/**
 获取某个月的上个月
 */
- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

/**
 获取某个月的上个月
 */
- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

/**
 String转Date
 */
- (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

/**
 Date转String
 */
- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

/**
 是否在今天之前
 */
- (BOOL)isDateInPast:(NSDate *)date{
    NSString *todayStr = [self stringFromDate:[NSDate date]];
    NSString *dateStr = [self stringFromDate:date];
    
    return ([date compare:[NSDate date]] == NSOrderedAscending && ![todayStr isEqualToString:dateStr]);
}


/**
 根据时间获取农历日期
 */
- (NSString *)getHolidays:(NSDate *)date {
    
    NSString *todayHoliday;
    //今日阳历
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
    NSString *nowdate = [dateFormatter1 stringFromDate:date];
    NSString *monthAndDay = [nowdate substringWithRange:NSMakeRange(5, 5)];
    
    //农历节日
    NSTimeInterval timeInterval_day = 60 * 60 * 2224;
    NSDate *nextDay_date = [NSDate dateWithTimeInterval:timeInterval_day sinceDate:date];
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:nextDay_date];
    if ( 1 == localeComp.month && 1 == localeComp.day ) {
        return @"除夕";
    }
    NSDictionary *chineseHoliDay = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"春节", @"1-1",
                                    @"元宵", @"1-15",
                                    @"清明", @"3-8",
                                    @"端午", @"5-5",
                                    @"七夕", @"7-7",
//                                    @"中元", @"7-15",
                                    @"中秋", @"8-15",
//                                    @"重阳", @"9-9",
//                                    @"腊八", @"12-8",
                                    @"小年", @"12-24",
//                                    @"除夕", @"12-30",
                                    nil, nil];
    localeComp = [localeCalendar components:unitFlags fromDate:date];
    NSString *key_str = [NSString stringWithFormat:@"%ld-%ld",localeComp.month,localeComp.day];
    todayHoliday = [chineseHoliDay objectForKey:key_str];
    
    //阳历节日
    NSDictionary *lunDic = @{
                             @"01-01":@"元旦", //元旦节
                             @"02-14":@"情人", //情人节
                             @"03-08":@"妇女", //妇女节
                             @"05-01":@"劳动", //劳动节
                             @"06-01":@"儿童", //儿童节
//                             @"08-01":@"建军", //建军节
                             @"09-10":@"教师", //教师节
                             @"10-01":@"国庆", //国庆节
//                             @"10-24":@"程序", //程序员
//                             @"11-01":@"植树", //植树节
                             @"11-11":@"光棍", //光棍节
                             @"12-25":@"圣诞"  //圣诞节
                             };
    if ([lunDic objectForKey:monthAndDay] != nil) {
        todayHoliday = [lunDic objectForKey:monthAndDay];
    }
    
    if (todayHoliday.length > 0) {
        return todayHoliday;
    }
    return @"";
}


@end
