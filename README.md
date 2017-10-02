# ZJCalender

[![CI Status](http://img.shields.io/travis/281925019@qq.com/ZJCalender.svg?style=flat)](https://travis-ci.org/281925019@qq.com/ZJCalender)
[![Version](https://img.shields.io/cocoapods/v/ZJCalender.svg?style=flat)](http://cocoapods.org/pods/ZJCalender)
[![License](https://img.shields.io/cocoapods/l/ZJCalender.svg?style=flat)](http://cocoapods.org/pods/ZJCalender)
[![Platform](https://img.shields.io/cocoapods/p/ZJCalender.svg?style=flat)](http://cocoapods.org/pods/ZJCalender)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ZJCalender is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZJCalender'
```

## Author

Jsoul1227@hotmail.com

## License

ZJCalender is available under the MIT license. See the LICENSE file for more info.

## MoreInfo
## 效果

###     1.简单多选全屏模式
![](http://osnabh9h1.bkt.clouddn.com/17-7-6/13600550.jpg)
###     1.多选半屏模式
![](http://osnabh9h1.bkt.clouddn.com/17-7-6/79678287.jpg)
###     1.多选全屏模式
![](http://osnabh9h1.bkt.clouddn.com/17-7-6/77214066.jpg)

## 类说明:

###     1.ZJCalenderController 日历控制器(全屏日历)
#### attribute:

```
calenderTitle(日历标题)
closeBlock(关闭日历回调)
```

###     2.ZJCalenderView 日历视图  (局部视图日历)
#### attribute:

```
selectedEnable(日历是否可选)
closeBlock(关闭日历回调)
```

#### method:

```
/**
实例化方法, ZJCalenderModePartScreen模式无法更改size
*/
- (instancetype)initWithFrame:(CGRect)frame calenderMode:(ZJCalenderMode)calenderMode;

/**
刷新数据
*/
- (void)reloadData;
```

###     3.ZJCalenderConst 常量宏 (各种颜色, 字体)
####     const

```
ZJCalenderThemeColor [主题色]
ZJCalenderHighlightThemeColor [高亮主题色]
ZJCalenderBackgroundColor [背景色]
ZJCalenderCommonTextColor [文字颜色]
ZJCalenderDisabledTextColor [不可选文字颜色]
ZJCalenderSelectedTextColor [选中文字颜色]
ZJCalenderSelectedBackgroundColor [选中背景色]
ZJCalenderDeselectedBackgroundColor [未选中背景色]
ZJCalenderMonthTitleColor [月标题色]
ZJCalenderMonthTitleBackgroundColor [月背景色]
ZJCalenderFirstSelectedText [第一次选中文字]
ZJCalenderSecondSelectedText [第二次选中文字]
ZJCalenderDisabledSelectedText [不可选文字]
```

###     4.ZJCalenderDateManager 日历控制单例对象 (日期, 功能, 回调)
#### attribute:

```
disabledDaysArray(不可选日期数组 @"2015-01-01"格式字符串)
disabledDateArray(不可选日期数组 NSDate  上面一个参数只会有一个生效, disabledDateArray优先)
selectedSinceToday(从今天开始可选, NO则从本月第一天开始可选 默认NO)
text(日期下面的统一文字)
simpleMode(简单模式, 只显示日期 ***此模式需每次推出日历之前设置一次***)
monthCount(传入生成模型的月份数量 默认4个月)
minSeletedDays(最少选择天数)
maxSeletedDays(最多选择天数)
multipleEnable(是否支持多选, 默认支持, 若不支持多选, block回调传选择日期相同)
selectedFail(点击失败回调)
finishSelect(选择完成回调 取消选择两天也会回调 传nil)
loadComplete(加载完成回调)
selectFinished(是否选中完成)
```

#### method:

```
/**
单粒快速创建
*/
+ (ZJCalenderDateManager *)sharedManager;

/**
生成模型数组
*/
- (void)getCalenderDateComplete:(completeBlock)complete;

/**
是否该显示文本
*/
- (BOOL)showTextWithDate:(NSDate *)date;

/**
重新获取日历的日期
*/
- (void)refreshDateComplete:(loadCompleteBlock)complete;

/**
清除选择
*/
- (void)clearSelection;
```
