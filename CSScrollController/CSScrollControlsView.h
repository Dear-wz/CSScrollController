//
//  CSScrollControlsView.h
//  CSScrollController
//
//  Created by work on 2018/5/12.
//  Copyright © 2018年 work. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSScrollControlsView;
@protocol CSScrollControlsViewDataSource <NSObject>
@required
- (NSArray<UIViewController*>*)controlOfScrollControlsView:(CSScrollControlsView *)scrollControlsView;
@end

@interface CSScrollControlsView : UIView
@property (nonatomic, assign) CGFloat scrollItemHeight; /** 头部的高度 => 默认40 */
@property (nonatomic, strong) UIColor *tintColor;       /** 头部的背景色 */
@property (nonatomic, assign) CGFloat space;            /** 头部按钮间距 => 默认10 */
@property (nonatomic, strong) UIColor *normalColor;     /** 头部按钮正常的颜色 */
@property (nonatomic, strong) UIColor *selectColor;     /** 头部按钮选中的颜色 */
@property (nonatomic, strong) UIFont  *titleFont;       /** 头部按钮的字体 */
@property (nonatomic, assign) BOOL  canScroll;          /** 控制器能否手动滚动 => 默认YES*/

@property (nonatomic, weak) id<CSScrollControlsViewDataSource> dataSource;  /** 控制器数据源 */
@end
