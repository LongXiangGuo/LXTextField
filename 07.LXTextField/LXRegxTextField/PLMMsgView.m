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

+ (instancetype)showMsg:(NSString*)msg onView:(UIView*)view offsetY:(CGFloat)offsetY {

    //1.superViews
    PLMMsgView* msgView = [[self alloc]init];
    view = [[UIApplication sharedApplication].windows lastObject];
    
    //2.detailLabel
    UILabel* label = [[UILabel alloc]init];
    label.text = msg;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.center = CGPointMake(label.bounds.size.width*0.5+(15), label.bounds.size.height*0.5 + (5));
    [msgView addSubview:label];
    
    msgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.68];
    msgView.layer.cornerRadius = (5);
    msgView.layer.masksToBounds = YES;
    msgView.bounds = CGRectMake(0, 0, label.bounds.size.width + (30), label.bounds.size.height + (10));
    CGFloat orignY ;
    if (offsetY > [UIScreen mainScreen].bounds.size.height* 0.5) {
        orignY = view.bounds.size.height - _msgView.bounds.size.height* 0.5 -(64);
    }else{
        orignY = msgView.bounds.size.height* 0.5 + (84);
    }
    msgView.center = CGPointMake(view.bounds.size.width*0.5, orignY);
    [view addSubview:msgView];
    [msgView performSelector:@selector(remove) withObject:msgView afterDelay:2];
    return msgView;
}

- (void)remove {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.2;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
   //[self hiddenAniamtion];
}

#pragma mark add and remove 
- (void)willMoveToSuperview:(UIView *)newSuperview {
 
   //[self showAniamtion];

}

#pragma mark animation
//- (void)showAniamtion {
//    CGFloat orignY = self.frame.origin.y < ([UIScreen mainScreen].bounds.size.height*0.5)? (84):[UIScreen mainScreen].bounds.size.height-self.bounds.size.height -(64);
//    CGFloat startY = self.frame.origin.y < ([UIScreen mainScreen].bounds.size.height*0.5)? (65):[UIScreen mainScreen].bounds.size.height -(45);
//    CGRect frame = self.frame;
//    frame.origin.y = startY;
//    self.frame =frame;
//    CGFloat height = self.bounds.size.height;
//    frame.size.height = 0;
//    self.bounds.size.height = cgrectmake;
//    self.layer.anchorPoint = CGPointMake(0.5,0.1);
//    [UIView animateWithDuration:0.2f animations:^{
//        self.frame.origin.y = orignY+Rate(5);
//        self.height = height;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.1 animations:^{
//            self.frame.origin..y = orignY;
//        }];
//    }];
//}
//- (void)hiddenAniamtion {
//    [UIView animateWithDuration:0.5f animations:^{
//         self.alpha = 0.5;
//    } completion:^(BOOL finished) {
//        [self removeFromSuperview];
//    }];
//}



@end
