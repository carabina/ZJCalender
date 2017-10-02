//
//  ZJCalenderCell.h
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJCalenderDayModel;

@interface ZJCalenderCell : UICollectionViewCell

/**
 日模型数据
 */
@property (nonatomic, strong) ZJCalenderDayModel *dayModel;


@end
