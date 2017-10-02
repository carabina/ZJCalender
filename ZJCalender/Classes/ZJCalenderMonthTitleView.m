//
//  ZJCalenderMonthTitleView.m
//  旅途逸居
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "ZJCalenderMonthTitleView.h"
#import "ZJCalenderConst.h"

@interface ZJCalenderMonthTitleView()
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZJCalenderMonthTitleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


- (void)setMonth:(NSInteger)month{
    _month = month;
    
    _titleLabel.text = [NSString stringWithFormat:@"%li月", month];
}


- (void)setupSubViews{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake((self.frame.size.width - ZJCalenderMonthTitleWidth) / 2, (self.frame.size.height - ZJCalenderMonthTitleHeight) / 2, ZJCalenderMonthTitleWidth, ZJCalenderMonthTitleHeight);
    _titleLabel.font = [UIFont systemFontOfSize:ZJCalenderCommonTextSize weight:UIFontWeightThin];
    _titleLabel.backgroundColor = ZJCalenderThemeColor;
    _titleLabel.textColor = ZJCalenderSelectedTextColor;
    _titleLabel.layer.cornerRadius = ZJCalenderMonthTitleHeight / 2;
    _titleLabel.layer.masksToBounds = YES;
    _titleLabel.layer.shouldRasterize = YES;
    _titleLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_titleLabel];
}

@end
