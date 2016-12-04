//
//  PLMMsgView.h
//  PLM
//
//  Created by tfs_ios on 16/7/28.
//  Copyright © 2016年 tritonsfs. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface PLMMsgView : UIView

+ (instancetype)showMsg:(NSString*)msg onView:(UIView*)view;

+ (instancetype)showMsg:(NSString*)msg onView:(UIView*)view offsetY:(CGFloat)offsetY;



@end
