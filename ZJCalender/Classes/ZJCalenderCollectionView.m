    //
//  ZJCalenderCollectionView.m
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#define ZJCalenderHeaderReusedId @"calenderHeaderReusedId"
#define ZJCalenderCellReusedId @"calenderCellReusedId"

#import "ZJCalenderCollectionView.h"
#import "ZJCalenderCell.h"
#import "ZJCalenderMonthTitleView.h"
#import "ZJCalenderMonthModel.h"
#import "ZJCalenderDayModel.h"
#import "ZJCalenderDateManager.h"
#import "ZJCalenderConst.h"

@interface ZJCalenderCollectionView() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) ZJCalenderDayModel *firstSelectedDayModel;
@property (nonatomic, strong) ZJCalenderDayModel *secondSelectedDayModel;

@property (nonatomic, strong) NSMutableArray *reloadIndexPathArray;
@property (nonatomic, strong) NSMutableArray *includedDayModelArray;

@property (nonatomic, strong) ZJCalenderDateManager *mgr;

@end

@implementation ZJCalenderCollectionView

#pragma mark ---lifeCycle---
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {

        [self prepare];
    }
    return self;
}


#pragma mark ---public---
- (void)setMonthModelArray:(NSMutableArray *)monthModelArray{
    if (!monthModelArray.count || (_monthModelArray.count && _mgr.isSimpleMode)) return;
    
    _monthModelArray = monthModelArray;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadComplete = NO;
        [UIView performWithoutAnimation:^{
            [self reloadData];
            self.loadComplete = YES;
            [self checkOutSelection];
            
            if (_calenderMode == ZJCalenderModePartScreen) {
                [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            }
        }];
    });
}


- (void)setCalenderMode:(ZJCalenderMode)calenderMode{
    _calenderMode = calenderMode;
    
    if (calenderMode == ZJCalenderModePartScreen) {
        self.scrollEnabled = NO;
    }
}


#pragma mark ---private---
- (void)prepare{
    self.backgroundColor = ZJCalenderBackgroundColor;
    self.layer.masksToBounds = NO;
    self.delegate = self;
    self.dataSource = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self registerClass:[ZJCalenderMonthTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ZJCalenderHeaderReusedId];
    [self registerClass:[ZJCalenderCell class] forCellWithReuseIdentifier:ZJCalenderCellReusedId];
    
    _mgr = [ZJCalenderDateManager sharedManager];
    
    _reloadIndexPathArray = [NSMutableArray array];
    _includedDayModelArray = [NSMutableArray array];
}


- (void)checkOutSelection{
    if (_mgr.lastFirstSelectedDayModel && _mgr.lastSecondSelectedDayModel) {
        if (!_mgr.lastFirstSelectedDayModel.monthModel && !_mgr.lastSecondSelectedDayModel.monthModel) {
            [_mgr clearSelection];
            return;
        }
        [self selectDayModel:_mgr.lastFirstSelectedDayModel];
        [self selectDayModel:_mgr.lastSecondSelectedDayModel];
    }
}


- (void)setLoadComplete:(BOOL)loadComplete{
    _loadComplete = loadComplete;
    if (loadComplete) {
        if (_mgr.loadComplete) {
            _mgr.loadComplete();
        }
    }
}


- (void)selectDayModel:(ZJCalenderDayModel *)dayModel{
    if (!dayModel.indexPath) return;
    
    [_reloadIndexPathArray addObject:dayModel.indexPath];
    
    if (_mgr.isMultipleEnable) { //多选模式
        
        if (dayModel.selectedEnable) { //点击的日可选
            
            switch (dayModel.selectedMode) {
                    
                case ZJCalenderSelectedModeFirst: //点击的日是第一次选择
                    
                    if (_secondSelectedDayModel) { //若第二次选择存在则清除
                        
                        [_reloadIndexPathArray addObject:_secondSelectedDayModel.indexPath];
                        
                        self.secondSelectedDayModel = nil;
                    } else { //若第二次选择的日不存在则清除第一次选择
                        
                        self.firstSelectedDayModel = nil;
                    }
                    break;
                    
                case ZJCalenderSelectedModeSecond: //点击的日是第二次选择
                    
                    //把这天变为第一次选择并置空第二次选择
                    [_reloadIndexPathArray addObject:_firstSelectedDayModel.indexPath];
                    
                    self.secondSelectedDayModel = nil;
                    self.firstSelectedDayModel = dayModel;
                    
                    break;
                    
                default: //点击的空白日
                    
                    if (!_firstSelectedDayModel) { //第一次选择不存在
                        
                        //把这一天变为第一次选择天数
                        self.firstSelectedDayModel = dayModel;
                        
                    } else if (!_secondSelectedDayModel){ //第一次选择存在,第二次选择不存在
                        
                        //把这一天变为第二次选择天数
                        [_reloadIndexPathArray addObject:_firstSelectedDayModel.indexPath];
                        self.secondSelectedDayModel = dayModel;
                        
                    } else if (dayModel.isIncluded) { //第一次选择第二次选择都存在 点击的这一天是被包括的天
                        
                        //把这一天变为第一次选择并置空第二次选择和被包括的天
                        [_reloadIndexPathArray removeObject:dayModel.indexPath]; //在firstSelectedDayModel setter方法中会再次标记这一天为可刷新 所以移除
                        [_reloadIndexPathArray addObject:_firstSelectedDayModel.indexPath];
                        [_reloadIndexPathArray addObject:_secondSelectedDayModel.indexPath];
                        self.secondSelectedDayModel = nil;
                        self.firstSelectedDayModel = dayModel;
                        
                    } else { //第一次选择第二次选择都存在 点击的这一天是没被包括的天
                        
                        //把这一天变为第一次选择并置空第二次选择和被包括的天
                        [_reloadIndexPathArray addObject:_firstSelectedDayModel.indexPath];
                        [_reloadIndexPathArray addObject:_secondSelectedDayModel.indexPath];
                        self.secondSelectedDayModel = nil;
                        self.firstSelectedDayModel = dayModel;
                    }
                    break;
            }
        } else if (_firstSelectedDayModel && !_secondSelectedDayModel) { //点击的日期不可选, 但可以作为第二次选择天
            
            [_reloadIndexPathArray addObject:_firstSelectedDayModel.indexPath];
            self.secondSelectedDayModel = dayModel;
            
        } else { //点击日期不可选, 直接回调
            
            if (_mgr.selectedFail) {
                _mgr.selectedFail(ZJSeletedFailReasonDateDisabled);
            }
        }
        
        //无动画刷新
        [UIView performWithoutAnimation:^{
            [self reloadItemsAtIndexPaths:_reloadIndexPathArray];
        }];
        
    } else { //单选模式
        
        if (dayModel.selectedEnable) { //日期可选 置空之前的日期并设为选中日期
            
            if ([_firstSelectedDayModel isEqual:dayModel]) {
               
                self.firstSelectedDayModel = nil;
            } else {
                if (_firstSelectedDayModel) {
                    [_reloadIndexPathArray addObject:_firstSelectedDayModel.indexPath];
                    self.firstSelectedDayModel = nil;
                }
                self.firstSelectedDayModel = dayModel;
            }
            
        } else { //日期不可选 回调
            
            if (_mgr.selectedFail) {
                _mgr.selectedFail(ZJSeletedFailReasonDateDisabled);
            }
        }
        
        //渐变动画刷新
        [self reloadItemsAtIndexPaths:_reloadIndexPathArray];
    }
    
    [_reloadIndexPathArray removeAllObjects];

}


- (void)setFirstSelectedDayModel:(ZJCalenderDayModel *)firstSelectedDayModel{
    
    //传值之前把上一个dayModel属性还原
    _firstSelectedDayModel.selectedMode = ZJCalenderSelectedModeNone;
    
    _firstSelectedDayModel = firstSelectedDayModel;
    _firstSelectedDayModel.selectedMode = ZJCalenderSelectedModeFirst;
    
    //在单选模式中 选择了一个日期直接回调
    if (firstSelectedDayModel && !_mgr.multipleEnable && _mgr.finishSelect) {
        _mgr.finishSelect(firstSelectedDayModel, firstSelectedDayModel);
    }
    
    if (!firstSelectedDayModel) {
        _mgr.finishSelect(nil, nil);
    }
}


- (void)setSecondSelectedDayModel:(ZJCalenderDayModel *)secondSelectedDayModel{
    
    //判断选择天数是否在manager中设置的限制之内
    if (![self isSelectedDaysInLimitWithSecondSeletedDay:secondSelectedDayModel]) {
        return;
    }
    
    //判断日期之间知否包含不可选日期
    if ([self isIncludeDisableDateWithSecondSeletedDay:secondSelectedDayModel]) {
        
        //若包含不可选日期 直接回调
        if (_mgr.selectedFail) {
            _mgr.selectedFail(ZJSeletedFailReasonIncludeDateDisabled);
        }
        return;
        
    } else {
        //若第二个日期小于第一个日期则交换
        NSComparisonResult result = [secondSelectedDayModel.date compare:_firstSelectedDayModel.date];
        if (result == NSOrderedAscending) {
            ZJCalenderDayModel *tempFirstDayModel = _firstSelectedDayModel;
            self.firstSelectedDayModel = nil;
            self.firstSelectedDayModel = secondSelectedDayModel;
            self.secondSelectedDayModel =  tempFirstDayModel;
            return;
        }
    }
    
    //传值之前把上一个dayModel属性还原
    _secondSelectedDayModel.selectedMode = ZJCalenderSelectedModeNone;
    
    _secondSelectedDayModel = secondSelectedDayModel;
    _secondSelectedDayModel.selectedMode = ZJCalenderSelectedModeSecond;
    
    //选好了离开日期完成选择 在mgr中标记并回调
    if (_secondSelectedDayModel && _firstSelectedDayModel) {
        _mgr.selectFinished = YES;
        if (_mgr.finishSelect) {
            _mgr.finishSelect(_firstSelectedDayModel, _secondSelectedDayModel);
        }
    }
}


- (BOOL)isSelectedDaysInLimitWithSecondSeletedDay:(ZJCalenderDayModel *)secondSelectedDayModel{
    
    if (!secondSelectedDayModel) return YES;
        
    ZJCalenderDayModel *firstDay = _firstSelectedDayModel;
    ZJCalenderDayModel *secondDay = secondSelectedDayModel;
    
    //根据日期交换前后
    NSComparisonResult result = [secondDay.date compare:firstDay.date];
    if (result == NSOrderedAscending) {
        firstDay = secondSelectedDayModel;
        secondDay = _firstSelectedDayModel;
    }
    
    //判断选中天数是否在限制内
    NSTimeInterval time = [secondDay.date timeIntervalSinceDate:firstDay.date];
    NSInteger selectedDayCount = (NSInteger) (time / 86400);
    if (selectedDayCount < _mgr.minSeletedDays) {
        if (_mgr.selectedFail) {
            _mgr.selectedFail(ZJSeletedFailReasonDaysCountLowerThanLimit);
        }
        return NO;
    } else if (selectedDayCount > _mgr.maxSeletedDays) {
        if (_mgr.selectedFail) {
            _mgr.selectedFail(ZJSeletedFailReasonDaysCountHigherThanLimit);
        }
        return NO;
    }
    return YES;
}


- (BOOL)isIncludeDisableDateWithSecondSeletedDay:(ZJCalenderDayModel *)secondSelectedDayModel{
    
    //若置空secondSelectedDayModel
    if (!secondSelectedDayModel) {
        //标记未完成选择
        _mgr.selectFinished = NO;
        
        //之前被包括的模型更改属性
        [_includedDayModelArray enumerateObjectsUsingBlock:^(ZJCalenderDayModel *dayModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [_reloadIndexPathArray addObject:dayModel.indexPath];
            dayModel.included = NO;
        }];
        [_includedDayModelArray removeAllObjects];
        
        return NO;
    }
    
    //判断两个日期先后
    ZJCalenderDayModel *firstDay = _firstSelectedDayModel;
    ZJCalenderDayModel *secondDay = secondSelectedDayModel;

    NSComparisonResult result = [secondDay.date compare:firstDay.date];
    if (result == NSOrderedAscending) {
        firstDay = secondSelectedDayModel;
        secondDay = _firstSelectedDayModel;
        
        _includedDayModelArray = nil;
    } else if (!_includedDayModelArray) {
        
        _includedDayModelArray = [NSMutableArray array];
    }
    
    NSInteger firstSelectedMonthIndex = [_monthModelArray indexOfObject:firstDay.monthModel];
    NSInteger secondSelectedMonthIndex = [_monthModelArray indexOfObject:secondDay.monthModel];
    NSInteger firstSelectedDayIndex = [firstDay.monthModel.dayModelArray indexOfObject:firstDay];
    NSInteger secondSelectedDayIndex = [secondDay.monthModel.dayModelArray indexOfObject:secondDay];
 
    //第一次第二次选择日期未同一个月
    if (firstSelectedMonthIndex == secondSelectedMonthIndex) {
        
        //遍历日 是否有不可选择的日子并储存被包含的天数
        ZJCalenderMonthModel *monthModel = _monthModelArray[firstSelectedMonthIndex];
        for (NSInteger d = firstSelectedDayIndex; d < secondSelectedDayIndex; d++) {
            
            ZJCalenderDayModel *dayModel = monthModel.dayModelArray[d];
            if (!dayModel.isSelectedEnable) {
                
                [_includedDayModelArray removeAllObjects];
                return YES;
            } else if (d != firstSelectedDayIndex) {
                
                [_includedDayModelArray addObject:dayModel];
            }
        }
        
    } else {//第一次第二次选择日期不在同一个月
        
        //遍历月
        for (NSInteger m = firstSelectedMonthIndex; m <= secondSelectedMonthIndex; m++) {
            
            ZJCalenderMonthModel *monthModel = _monthModelArray[m];
            if (m == firstSelectedMonthIndex) { //遍历至第一次选择的月
                
                //遍历日 是否有不可选择的日子并储存被包含的天数
                for (NSInteger d = firstSelectedDayIndex; d < monthModel.dayCount; d++) {
                    
                    ZJCalenderDayModel *dayModel = monthModel.dayModelArray[d];
                    if (!dayModel.isSelectedEnable) {
                        
                        [_includedDayModelArray removeAllObjects];
                        return YES;
                    } else if (d != firstSelectedDayIndex) {
                        
                        [_includedDayModelArray addObject:dayModel];
                    }
                }
            } else if (m == secondSelectedMonthIndex) { //遍历至第二次选择的月

                //遍历日 是否有不可选择的日子并储存被包含的天数
                for (NSInteger d = 0; d < secondSelectedDayIndex; d++) {
                    
                    ZJCalenderDayModel *dayModel = monthModel.dayModelArray[d];
                    if (!dayModel.isSelectedEnable) {
                        
                        [_includedDayModelArray removeAllObjects];
                        return YES;
                    } else {
                        
                        [_includedDayModelArray addObject:dayModel];
                    }
                }
            } else { //遍历至不为第一次第二次选择的月
                
                //遍历日 是否有不可选择的日子并储存被包含的天数
                for (NSInteger d = 0; d < monthModel.dayCount; d++) {
                    
                    ZJCalenderDayModel *dayModel = monthModel.dayModelArray[d];
                    if (!dayModel.isSelectedEnable) {
                        
                        [_includedDayModelArray removeAllObjects];
                        return YES;
                    } else {
                        
                        [_includedDayModelArray addObject:dayModel];
                    }
                }
            }
        }
    }
    
    //若到这一步则没有包含不可选日, 标记所有储存的被包含天数为被包含
    [_includedDayModelArray enumerateObjectsUsingBlock:^(ZJCalenderDayModel *dayModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [_reloadIndexPathArray addObject:dayModel.indexPath];
        dayModel.included = YES;
    }];
    
    return NO;
}


#pragma mark ---collectionViewDelegate---
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _monthModelArray.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    ZJCalenderMonthModel *monthModel = _monthModelArray[section];
    return monthModel.dayCount + monthModel.firstDayWeek;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZJCalenderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ZJCalenderCellReusedId forIndexPath:indexPath];
    
    if (_monthModelArray.count) {
        ZJCalenderMonthModel *monthModel = _monthModelArray[indexPath.section];
        NSInteger dayIndex = indexPath.item - monthModel.firstDayWeek;
        if (dayIndex < 0) {
            cell.dayModel = nil;
        } else {
            ZJCalenderDayModel *dayModel = monthModel.dayModelArray[dayIndex];
            dayModel.indexPath = indexPath;
            cell.dayModel = dayModel;
        }
    }
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{

    return CGSizeMake(self.frame.size.width, ZJCalenderMonthTitleViewHeight);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{

    return section == _monthModelArray.count - 1 ? CGSizeMake(self.frame.size.width, ZJCalenderMonthTitleViewHeight) : CGSizeZero;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
   
    ZJCalenderMonthTitleView *cell = (ZJCalenderMonthTitleView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ZJCalenderHeaderReusedId forIndexPath:indexPath];
    ZJCalenderMonthModel *monthModel = _monthModelArray[indexPath.section];
    cell.month = monthModel.month;
    
    if (_calenderMode == ZJCalenderModePartScreen || [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        cell.hidden = YES;
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ZJCalenderMonthModel *monthModel = _monthModelArray[indexPath.section];
    
    NSInteger dayIndex = indexPath.item - monthModel.firstDayWeek;
    ZJCalenderDayModel *dayModel = monthModel.dayModelArray[dayIndex];
    
    [self selectDayModel:dayModel];
}

@end
