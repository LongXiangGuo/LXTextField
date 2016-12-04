//
//  TFSButton.h
//  验证码按钮
//
//  Created by tfs_ios on 16/5/11.
//  Copyright © 2016年 tritonsfs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLMCodeBtn : UIButton

@property (strong, nonatomic) NSString* title_normal;
@property (assign, nonatomic,getter=isStartByOtherBtn) BOOL startByOtherBtn;
/**
 * @brief  创建一个倒计是Button并添加回调Block
 * @param  <#agr1#>
 * @param  <#agr2#>
 * @return  <#agr3#>
 */
@property (strong, nonatomic) NSString* title_selected;
@property (strong, nonatomic) NSTimer* timer;
- (PLMCodeBtn* )initWithTitle:(NSString*)title touchBlock:(void (^)(PLMCodeBtn *btn))touchBlock;

- (void)startTimer;

@end
