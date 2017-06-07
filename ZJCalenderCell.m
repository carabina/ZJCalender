//
//  ZJCalenderCell.m
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "ZJCalenderCell.h"
#import "ZJCalenderDayModel.h"
#import "ZJCalenderDateManager.h"
#import "ZJCalenderConst.h"

@interface ZJCalenderCell()
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *leftFlatBgView;
@property (nonatomic, strong) UIView *rightFlatBgView;
@property (nonatomic, strong) UIImageView *roundBgView;

@end

@implementation ZJCalenderCell

#pragma mark ---lifeCycle---
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = ZJCalenderBackgroundColor;
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark ---public---
- (void)setDayModel:(ZJCalenderDayModel *)dayModel{
    _dayModel = dayModel;
    if (!dayModel) {
        self.userInteractionEnabled = NO;
    } else {
        self.userInteractionEnabled = YES;
    }
    
    [self setupColor];
    
    [self setupStatus];
    
    [self updateFrame];
}


#pragma mark ---private---
- (void)setupColor{
    
    if (_dayModel.isSelectedEnable) {
        
        if (_dayModel.selectedMode == ZJCalenderSelectedModeFirst) {
            if ([ZJCalenderDateManager sharedManager].isSelectFinished) {
                [self selectedFirstTheme];
            } else {
                [self selectedTheme];
            }
        } else if (_dayModel.selectedMode == ZJCalenderSelectedModeSecond) {
            [self selectedSecondTheme];
        } else if (_dayModel.isIncluded) {
            [self includeTheme];
        } else {
            [self selectedEnableTheme];
        }
    } else if (_dayModel.selectedMode == ZJCalenderSelectedModeSecond){
        [self selectedSecondTheme];
    } else {
        [self selectedDisableTheme];
    }
}


//不可选状态
- (void)selectedDisableTheme{
    _leftFlatBgView.backgroundColor = ZJCalenderBackgroundColor;
    _rightFlatBgView.backgroundColor = ZJCalenderBackgroundColor;
    _roundBgView.tintColor = [UIColor clearColor];
    _dayLabel.textColor = ZJCalenderDisabledTextColor;
    _textLabel.textColor = ZJCalenderDisabledTextColor;
}


//可选状态
- (void)selectedEnableTheme{
    _leftFlatBgView.backgroundColor = ZJCalenderBackgroundColor;
    _rightFlatBgView.backgroundColor = ZJCalenderBackgroundColor;
    _roundBgView.tintColor = [UIColor clearColor];
    _dayLabel.textColor = ZJCalenderCommonTextColor;
    _textLabel.textColor = ZJCalenderCommonTextColor;
}


//选中状态 只有起始日期
- (void)selectedTheme{
    _leftFlatBgView.backgroundColor = [UIColor clearColor];
    _rightFlatBgView.backgroundColor = [UIColor clearColor];
    _roundBgView.tintColor = ZJCalenderThemeTintColor;
    _dayLabel.textColor = ZJCalenderSelectedTextColor;
    _textLabel.textColor = ZJCalenderSelectedTextColor;
}


//选中状态 起始日期
- (void)selectedFirstTheme{
    _leftFlatBgView.backgroundColor = [UIColor clearColor];
    _rightFlatBgView.backgroundColor = ZJCalenderThemeColor;
    _roundBgView.tintColor = ZJCalenderHighlightThemeColor;
    _dayLabel.textColor = ZJCalenderSelectedTextColor;
    _textLabel.textColor = ZJCalenderSelectedTextColor;
}


//选中状态 终止日期
- (void)selectedSecondTheme{
    _leftFlatBgView.backgroundColor = ZJCalenderThemeColor;
    _rightFlatBgView.backgroundColor = [UIColor clearColor];
    _roundBgView.tintColor = ZJCalenderHighlightThemeColor;
    _dayLabel.textColor = ZJCalenderSelectedTextColor;
    _textLabel.textColor = ZJCalenderSelectedTextColor;
}


//包括状态
- (void)includeTheme{
    _leftFlatBgView.backgroundColor = ZJCalenderThemeColor;
    _rightFlatBgView.backgroundColor = ZJCalenderThemeColor;
    _roundBgView.tintColor = [UIColor clearColor];
    _dayLabel.textColor = ZJCalenderSelectedTextColor;
    _textLabel.textColor = ZJCalenderSelectedTextColor;
}


- (void)setupStatus{
    
    if (_dayModel) {
        _dayLabel.hidden = NO;
        if ([ZJCalenderDateManager sharedManager].isSimpleMode) {
            _dayLabel.text = [NSString stringWithFormat:@"%li", _dayModel.day];
            _textLabel.hidden = YES;
        } else {
            _dayLabel.text = _dayModel.holiday.length ? _dayModel.holiday : [NSString stringWithFormat:@"%li", _dayModel.day];
            if (_dayModel.text.length) {
                _textLabel.hidden = NO;
                _textLabel.text = _dayModel.text;
            } else {
                _textLabel.hidden = YES;
            }
        }
    } else {
        _textLabel.hidden = YES;
        _dayLabel.hidden = YES;
    }
}


- (void)updateFrame{
    
    if (_textLabel.hidden) {
        _dayLabel.center = self.contentView.center;
    } else {
        _dayLabel.center = CGPointMake(self.contentView.center.x, self.contentView.frame.size.height * 1 / 4);
        _textLabel.center = CGPointMake(self.contentView.center.x, self.contentView.frame.size.height * 3 / 4);
    }
}


- (void)setupSubViews{
    _dayLabel = [self createLabel];
    
    _textLabel = [self createLabel];
    _textLabel.font = [UIFont systemFontOfSize:ZJCalenderSmallTextSize weight:UIFontWeightLight];
    
    UIImage *roundBgImg = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", ZJCalenderBundle, @"ZJCalenderRoundBgView"]];
    roundBgImg = [roundBgImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _roundBgView = [[UIImageView alloc] initWithImage:roundBgImg];
    _roundBgView.tintColor = [UIColor clearColor];
    _roundBgView.frame = self.contentView.bounds;
    _roundBgView.layer.masksToBounds = YES;
    
    [self.contentView insertSubview:_roundBgView atIndex:0];
    
    CGFloat leftFlatBgY = 0;
    CGFloat leftFlatBgW = (self.contentView.frame.size.width + ZJCalenderItemSpacing) / 2;
    CGFloat leftFlatBgH = self.contentView.frame.size.height;
    CGFloat leftFlatBgX = -leftFlatBgW + self.contentView.frame.size.width / 2;
    _leftFlatBgView = [[UIView alloc] initWithFrame:CGRectMake(leftFlatBgX, leftFlatBgY, leftFlatBgW, leftFlatBgH)];
    _leftFlatBgView.backgroundColor = ZJCalenderBackgroundColor;
    [self.contentView insertSubview:_leftFlatBgView belowSubview:_roundBgView];
    
    CGFloat rightFlatBgY = 0;
    CGFloat rightFlatBgW = (self.contentView.frame.size.width + ZJCalenderItemSpacing) / 2;
    CGFloat rightFlatBgH = self.contentView.frame.size.height;
    CGFloat rightFlatBgX = self.contentView.frame.size.width / 2;
    _rightFlatBgView = [[UIView alloc] initWithFrame:CGRectMake(rightFlatBgX, rightFlatBgY, rightFlatBgW, rightFlatBgH)];
    _rightFlatBgView.backgroundColor = ZJCalenderBackgroundColor;
    [self.contentView insertSubview:_rightFlatBgView belowSubview:_roundBgView];
}


- (UILabel *)createLabel{
    UILabel *label = [[UILabel alloc] init];
    label.bounds = CGRectMake(0, 0, self.contentView.frame.size.width * 2, self.contentView.frame.size.height / 2);
    label.font = [UIFont systemFontOfSize:ZJCalenderCommonTextSize weight:UIFontWeightLight];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = ZJCalenderCommonTextColor;
    
    [self addSubview:label];
    return label;
}

@end
