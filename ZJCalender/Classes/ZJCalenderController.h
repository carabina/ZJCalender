//
//  ZJCalenderController.h
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//
/******************************
 
 在DateManager中设置回调等
 UI在Const文件中更改
 
 *****************************/

#import <UIKit/UIKit.h>
#import "ZJCalenderDateManager.h"
#import "ZJCalenderDayModel.h"

typedef void(^closeBlock)();

@interface ZJCalenderController : UIViewController

/**
 标题
 */
@property (nonatomic, copy) NSString *calenderTitle;

/**
 关闭回调
 */
@property (nonatomic, copy) closeBlock closeBlock;

@end
