//
//  ZJCalenderController.m
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "ZJCalenderController.h"
#import "ZJCalenderView.h"
#import "ZJCalenderConst.h"

@interface ZJCalenderController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) ZJCalenderView *calenderView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, assign, getter=isStatusBarOrginHidden) BOOL statusBarOrginHidden;

@end

@implementation ZJCalenderController

#pragma mark ---lifeCycle---
- (instancetype)init{
    if (self = [super init]) {
        //[ZJCalenderDateManager sharedManager].simpleMode = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepare];
    
    [self setupTitleLabel];
    
    [self setupCalenderView];
    
    [self setupCloseBtn];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarOrginHidden];
}


#pragma mark ---UI---
- (void)setupTitleLabel{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2 * ZJPadding, ZJScreenWidth, ZJCalenderLargeTextSize)];
    _titleLabel.font = [UIFont systemFontOfSize:ZJCalenderLargeTextSize weight:UIFontWeightLight];
    _titleLabel.textColor = ZJCalenderCommonTextColor;
    _titleLabel.backgroundColor = ZJCalenderBackgroundColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"日历";
    
    [self.view addSubview:_titleLabel];
}


- (void)setupCalenderView{
    CGFloat calenderX = 0;
    CGFloat calenderY = CGRectGetMaxY(_titleLabel.frame);
    CGFloat calenderW = self.view.frame.size.width;
    CGFloat calenderH = self.view.frame.size.height - calenderY;

    _calenderView = [[ZJCalenderView alloc] initWithFrame:CGRectMake(calenderX, calenderY, calenderW, calenderH) calenderMode:ZJCalenderModeFullScreen];
    
    [self.view insertSubview:_calenderView atIndex:0];
}


- (void)setupCloseBtn{
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.frame = CGRectMake(0, ZJScreenHeight - 44, ZJScreenWidth, 44);
    [_closeBtn setBackgroundColor:ZJCalenderBackgroundColor];
    [_closeBtn setImage:[self bundleImageNamed:@"ZJClenderArrowImg"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *colorOne = [ZJCalenderBackgroundColor colorWithAlphaComponent:0.0];
    UIColor *colorTwo = [ZJCalenderBackgroundColor colorWithAlphaComponent:1.0];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    CAGradientLayer *shadowLayer = [CAGradientLayer layer];
    shadowLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    shadowLayer.locations = @[stopOne, stopTwo];
    shadowLayer.frame = CGRectMake(0, -20, _closeBtn.frame.size.width, 20);
    [_closeBtn.layer addSublayer:shadowLayer];
    
    [self.view addSubview:_closeBtn];
}


#pragma mark ---userInteraction---
- (void)closeBtnClicked{
    if (self.closeBlock) {
        self.closeBlock();
    }
    
    [[ZJCalenderDateManager sharedManager] clearSelection];
    [ZJCalenderDateManager sharedManager].simpleMode = NO;
    [ZJCalenderDateManager sharedManager].multipleEnable = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark ---public---
- (void)setCalenderTitle:(NSString *)calenderTitle{
    _calenderTitle = calenderTitle;
    
    _titleLabel.text = calenderTitle;
}


#pragma mark ---private---
- (void)prepare{
    self.view.backgroundColor = ZJCalenderBackgroundColor;
    
    _statusBarOrginHidden = [UIApplication sharedApplication].statusBarHidden;
}


- (UIImage *)bundleImageNamed:(NSString *)imageName{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", ZJCalenderBundle, imageName]];
}
@end
