//
//  ZJCalenderDayModel.m
//
//
//  Created by Zj on 17/3/25.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "ZJCalenderDayModel.h"
#import "ZJCalenderDateManager.h"
#import "ZJCalenderConst.h"

@implementation ZJCalenderDayModel

- (void)setText:(NSString *)text{
    
    if (![text isEqualToString:ZJCalenderFirstSelectedText] && ![text isEqualToString:ZJCalenderSecondSelectedText]) {
        _orginText = text;
    } else {
        _orginText = text.length ? text : _orginText;
    }
    
    ZJCalenderDateManager *mgr = [ZJCalenderDateManager sharedManager];
    _text = [mgr showTextWithDate:_date] ? text : nil;
}


- (void)setSelectedMode:(ZJCalenderSelectedMode)selectedMode{
    
    _selectedMode = selectedMode;
    
    switch (selectedMode) {
        case ZJCalenderSelectedModeFirst:
            _text = [ZJCalenderDateManager sharedManager].isMultipleEnable ? ZJCalenderFirstSelectedText : nil;
            break;
            
        case ZJCalenderSelectedModeSecond:
            _text = ZJCalenderSecondSelectedText;
            break;
            
        default:
            _text = _orginText;
            break;
    }
}


- (void)setSelectedEnable:(BOOL)selectedEnable{
    _selectedEnable = selectedEnable;
    
    ZJCalenderDateManager *mgr = [ZJCalenderDateManager sharedManager];
    if (!selectedEnable && [mgr showTextWithDate:_date]) {
        self.text = ZJCalenderDisabledSelectedText;
    }
}




@end
