//
//  PLMMsgView.m
//  PLM
//
//  Created by tfs_ios on 16/7/28.
//  Copyright © 2016年 tritonsfs. All rights reserved.
//

#import "PLMMsgView.h"
@interface PLMMsgView()

@end

@implementation PLMMsgView

static PLMMsgView* _msgView = nil;
+ (instancetype)showMsg:(NSString*)msg onView:(UIView*)view {
    
    //1.superViews
    PLMMsgView* msgView = [[self alloc]init];
    view = [[UIApplication sharedApplication].windows lastObject];
    
    //2.detailLabel
    UILabel* label = [[UILabel alloc]init];
    label.text = msg;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = Font_Size_13;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.center = CGPointMake(label.width*0.5+Rate(15), label.height*0.5 + Rate(5));
    [msgView addSubview:label];
    
    msgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.68];
    msgView.layer.cornerRadius = Rate(5);
    msgView.layer.masksToBounds = YES;
    msgView.bounds = CGRectMake(0, 0, label.width + Rate(30), label.height + Rate(10));
    msgView.center = CGPointMake(view.width*0.5, view.height - _msgView.height* 0.5 -Rate(20));
    
    [view addSubview:msgView];
    [msgView performSelector:@selector(remove) withObject:msgView afterDelay:2];
    return msgView;
}

+ (instancetype)showMsg:(NSString*)msg onView:(UIView*)view offsetY:(CGFloat)offsetY {

    //1.superViews
    PLMMsgView* msgView = [[self alloc]init];
    view = [[UIApplication sharedApplication].windows lastObject];
    
    //2.detailLabel
    UILabel* label = [[UILabel alloc]init];
    label.text = msg;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = Font_Size_13;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.center = CGPointMake(label.width*0.5+Rate(15), label.height*0.5 + Rate(5));
    [msgView addSubview:label];
    
    msgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.68];
    msgView.layer.cornerRadius = Rate(5);
    msgView.layer.masksToBounds = YES;
    msgView.bounds = CGRectMake(0, 0, label.width + Rate(30), label.height + Rate(10));
    CGFloat orignY ;
    if (offsetY > screenHeight* 0.5) {
        orignY = view.height - _msgView.height* 0.5 -Rate(64);
    }else{
        orignY = msgView.height* 0.5 + Rate(84);
    }
    msgView.center = CGPointMake(view.width*0.5, orignY);
    [view addSubview:msgView];
    [msgView performSelector:@selector(remove) withObject:msgView afterDelay:2];
    return msgView;
}

- (void)remove {
   [self hiddenAniamtion];
}

#pragma mark add and remove 
- (void)willMoveToSuperview:(UIView *)newSuperview {
 
   [self showAniamtion];

}

#pragma mark animation
- (void)showAniamtion {
    CGFloat orignY = self.y < (screenHeight*0.5)? Rate(84):screenHeight-self.height -Rate(64);
    CGFloat startY = self.y < (screenHeight*0.5)? Rate(65):screenHeight -Rate(45);
    self.y = startY;
    CGFloat height = self.height;
    self.height = Rate(0);
    self.layer.anchorPoint = CGPointMake(0.5,0.1);
    [UIView animateWithDuration:0.2f animations:^{
        self.y = orignY+Rate(5);
        self.height = height;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.y = orignY;
        }];
    }];
}
- (void)hiddenAniamtion {
    [UIView animateWithDuration:0.5f animations:^{
         self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



@end
