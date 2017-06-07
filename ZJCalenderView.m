//
//  ZJCalenderView.m
//  
//
//  Created by 张骏 on 17/3/28.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "ZJCalenderView.h"
#import "ZJCalenderCollectionView.h"
#import "ZJCalenderDateManager.h"
#import "ZJCalenderMonthModel.h"
#import "ZJCalenderConst.h"

@interface ZJCalenderView()
@property (nonatomic, strong) ZJCalenderCollectionView *calenderCollectionView;
@property (nonatomic, strong) UIView *swichView;
@property (nonatomic, strong) UIView *weekView;
@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UIButton *lastMonthBtn;
@property (nonatomic, strong) UIButton *nextMonthBtn;
@property (nonatomic, strong) NSMutableArray *monthModelArray;
@property (nonatomic, assign) NSInteger visibleIndex;
@property (nonatomic, assign) ZJCalenderMode calenderMode;

@end

@implementation ZJCalenderView

#pragma mark ---lifeCycle---

- (instancetype)initWithFrame:(CGRect)frame calenderMode:(ZJCalenderMode)calenderMode{
    
    if (calenderMode == ZJCalenderModePartScreen) {
        frame = CGRectMake(0, frame.origin.y, ZJScreenWidth, ZJCalenderPartScreenHeight);
    }
    
    if (self = [super initWithFrame:frame]) {
       
        self.calenderMode = calenderMode;
        
        self.layer.masksToBounds = YES;
        
        self.selectedEnable = YES;
    
        [self setupSwichView];
        
        [self setupWeekView];
        
        [self setupCalenderView];
        
        [self setupCalenderDate];
    }
    return self;
}


- (void)dealloc{
    [ZJCalenderDateManager sharedManager].selectFinished = NO;
}


#pragma mark ---public---
- (void)setFrame:(CGRect)frame{
    if (_calenderMode == ZJCalenderModePartScreen) {
        CGRect rect = CGRectMake(0, 0, ZJScreenWidth, ZJCalenderPartScreenHeight);
        rect.origin.y = frame.origin.y;
        [super setFrame:rect];
    } else {
        [super setFrame:frame];
    }
}


- (void)setVisibleIndex:(NSInteger)visibleIndex{
    _visibleIndex = visibleIndex;
    
    if (_calenderMode == ZJCalenderModePartScreen) {
        ZJCalenderMonthModel *monthModel = _monthModelArray[visibleIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            _monthLabel.text = [NSString stringWithFormat:@"%zd年%zd月", monthModel.year, monthModel.month];
        });
    }
}


- (void)setSelectedEnable:(BOOL)selectedEnable{
    _selectedEnable = selectedEnable;
    
    _calenderCollectionView.userInteractionEnabled = selectedEnable;
}


- (void)reloadData{
    [self setupCalenderDate];
}


#pragma mark ---userInteraction---
- (void)swichBtnClicked:(UIButton *)sender{

    switch (sender.tag) {
        case 0:
            self.visibleIndex -= 1;
            _nextMonthBtn.enabled = YES;
            [_calenderCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:_visibleIndex] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            if (_visibleIndex == 0) _lastMonthBtn.enabled = NO;
            break;
            
        default:
            self.visibleIndex += 1;
            _lastMonthBtn.enabled = YES;
            [_calenderCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:_visibleIndex] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            if (_visibleIndex == _monthModelArray.count - 1) _nextMonthBtn.enabled = NO;
            break;
    }
}


#pragma mark ---private---
- (UIButton *)createButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = ZJCalenderBackgroundColor;
    [btn addTarget:self action:@selector(swichBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


- (UIImage *)bundleImageNamed:(NSString *)imageName{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", ZJCalenderBundle, imageName]];
}


#pragma mark ---UI---
- (void)setupSwichView{
    if (_calenderMode == ZJCalenderModeFullScreen) return;
    
    _swichView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ZJScreenWidth, ZJCalenderPartScreenSwichViewHeight)];
    _swichView.backgroundColor = ZJCalenderBackgroundColor;
    
    [self addSubview:_swichView];
    
    _monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ZJScreenWidth, ZJCalenderPartScreenSwichViewHeight)];
    _monthLabel.textAlignment = NSTextAlignmentCenter;
    _monthLabel.textColor = ZJCalenderCommonTextColor;
    _monthLabel.font = [UIFont systemFontOfSize:ZJCalenderLargeTextSize weight:UIFontWeightLight];
    _monthLabel.backgroundColor = ZJCalenderBackgroundColor;
    _monthLabel.layer.masksToBounds = YES;
    
    [_swichView addSubview:_monthLabel];

    _lastMonthBtn = [self createButton];
    _lastMonthBtn.tag = 0;
    _lastMonthBtn.frame = CGRectMake(0, 0, 50, ZJCalenderPartScreenSwichViewHeight);
    _lastMonthBtn.enabled = NO;
    [_lastMonthBtn setImage:[self bundleImageNamed:@"ZJCalenderLastImg"] forState:UIControlStateNormal];
    [_swichView addSubview:_lastMonthBtn];
    
    _nextMonthBtn = [self createButton];
    _nextMonthBtn.tag = 1;
    _nextMonthBtn.enabled = NO;
    _nextMonthBtn.frame = CGRectMake(ZJScreenWidth - 50, 0, 50, ZJCalenderPartScreenSwichViewHeight);
    [_nextMonthBtn setImage:[self bundleImageNamed:@"ZJCalenderNextImg"] forState:UIControlStateNormal];
    [_swichView addSubview:_nextMonthBtn];
}


- (void)setupWeekView{
    CGFloat weekX = 0;
    CGFloat weekY = CGRectGetMaxY(_swichView.frame);
    CGFloat weekW = self.frame.size.width;
    CGFloat weekH = ZJCalenderWeekViewHeight;
    
    _weekView = [[UIView alloc] initWithFrame:CGRectMake(weekX, weekY, weekW, weekH)];
    _weekView.backgroundColor = ZJCalenderBackgroundColor;
    
    CGFloat weekDayWidth = (weekW - 2 * LTPadding - 6 * ZJCalenderItemSpacing)/ 7;
    
    for (NSInteger i = 0; i < 7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(LTPadding + (weekDayWidth + ZJCalenderItemSpacing) * i, (ZJCalenderWeekViewHeight - weekDayWidth) / 2 + LTPadding, weekDayWidth, ZJCalenderCommonTextSize)];
        label.font = [UIFont systemFontOfSize:ZJCalenderCommonTextSize weight:UIFontWeightLight];
        label.textColor = ZJCalenderDisabledTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = ZJCalenderBackgroundColor;
        
        switch (i) {
            case 0:
                label.text = @"日";
                label.textColor = ZJCalenderThemeColor;
                break;
                
            case 1:
                label.text = @"一";
                break;
                
            case 2:
                label.text = @"二";
                break;
                
            case 3:
                label.text = @"三";
                break;
                
            case 4:
                label.text = @"四";
                break;
                
            case 5:
                label.text = @"五";
                break;
                
            default:
                label.text = @"六";
                label.textColor = ZJCalenderThemeColor;
                break;
        }
        
        [_weekView addSubview:label];
    }
    
    [self addSubview:_weekView];
    
    if (_calenderMode == ZJCalenderModePartScreen) return;
    
    UIColor *colorOne = [ZJCalenderBackgroundColor colorWithAlphaComponent:1.0];
    UIColor *colorTwo = [ZJCalenderBackgroundColor colorWithAlphaComponent:0.0];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    shadowLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    shadowLayer.locations = @[stopOne, stopTwo];
    shadowLayer.frame = CGRectMake(0, _weekView.frame.size.height, _weekView.frame.size.width, 10);
    [_weekView.layer addSublayer:shadowLayer];
}


- (void)setupCalenderView{
    
    CGFloat calenderX = ZJPadding;
    CGFloat calenderY = CGRectGetMaxY(_weekView.frame);
    CGFloat calenderW = self.frame.size.width - 2 * ZJPadding;
    CGFloat calenderH = self.frame.size.height - calenderY;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = _calenderMode == ZJCalenderModeFullScreen ? ZJCalenderLineFullScreenSpacing : ZJCalenderLinePartScreenSpacing;
    layout.minimumInteritemSpacing = ZJCalenderItemSpacing;
    CGFloat itemWidth = (calenderW - 6 * ZJCalenderItemSpacing) / 7;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    _calenderCollectionView = [[ZJCalenderCollectionView alloc] initWithFrame:CGRectMake(calenderX, calenderY, calenderW, calenderH) collectionViewLayout:layout];
    _calenderCollectionView.calenderMode = _calenderMode;
    _calenderCollectionView.monthModelArray = _monthModelArray.count ? _monthModelArray : nil;
    
    [self insertSubview:_calenderCollectionView atIndex:0];
}


- (void)setupCalenderDate{
    WeakObj(self);
    [[ZJCalenderDateManager sharedManager] getCalenderDateComplete:^(NSMutableArray *monthModelArray) {
        if (selfWeak.calenderCollectionView) {
            selfWeak.calenderCollectionView.monthModelArray = monthModelArray;
        }
        selfWeak.monthModelArray = monthModelArray;
        selfWeak.visibleIndex = 0;
        _nextMonthBtn.enabled = YES;
    }];
}

@end
