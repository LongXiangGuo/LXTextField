//
//  TFSButton.m
//  验证码按钮
//
//  Created by tfs_ios on 16/5/11.
//  Copyright © 2016年 tritonsfs. All rights reserved.
//

#import "PLMCodeBtn.h"
#define MaxSeconds 60
typedef void(^TouchBtn)(PLMCodeBtn* btn);
@interface PLMCodeBtn()
{
    TouchBtn  _touchBlock;
    NSInteger _times;
    NSDate*   _goBackgroundDate;
}

@end

@implementation PLMCodeBtn

- (PLMCodeBtn* )initWithTitle:(NSString*)title touchBlock:(void (^)(PLMCodeBtn *btn))touchBlock {
    if (self = [super init]) {
        _touchBlock = touchBlock;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self restStatus];
        if (self.tag == 1000) {
            self.titleLabel.font = [UIFont systemFontOfSize:17];
        }
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitle:self.title_selected forState:UIControlStateSelected];
        [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(clickSelfBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self sizeToFit];
        self.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    return self;
}

- (void)restStatus {
    //btn初始化设置
    self.userInteractionEnabled  = YES;
    self.selected = NO;
    [self setTitle:@"重新获取" forState:UIControlStateNormal];
    [_timer invalidate];
    _timer = nil;
    _times = MaxSeconds;
}


- (void)clickSelfBtn:(PLMCodeBtn*)btn {
    if (btn.userInteractionEnabled == NO) {
        return;
    }
    if (self.isStartByOtherBtn == NO) {
       [btn startTimer];
    }
    _touchBlock(btn);  //do anything click btn
}

- (void)startTimer {
    self.selected = YES;
    self.userInteractionEnabled  = NO;
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(showLastTime) userInfo:nil repeats:YES];
    _timer.fireDate = [NSDate distantPast];
    [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}


- (void)showLastTime {
    if (_times < 0) {
        [self restStatus];
        return;
    }
    
    self.title_selected = [NSString stringWithFormat:@"%ld秒",_times];
    if (self.tag == 1000) {
        self.title_selected = [NSString stringWithFormat:@"获取验证码(%ld秒)",_times];
    }
    [self setTitle:self.title_selected forState:UIControlStateSelected];
    _times--;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    //[self startTimer];
}

#pragma mark notificaitons
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidEnterBackground:) name:@"appDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidBecomeActive:) name:@"appDidBecomeActive" object:nil];
}

- (void)removeNotificaitons {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"appDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"appDidBecomeActive" object:nil];
    
}

- (void)appDidEnterBackground:(NSNotification*)notify {
    _goBackgroundDate = [NSDate date];
}
- (void)appDidBecomeActive:(NSNotification*)notify {
    NSTimeInterval detaTimer = [[NSDate date]timeIntervalSinceDate:_goBackgroundDate];
    _times -= (NSInteger)(detaTimer+1);
    [self showLastTime];
}

- (void)dealloc {
    [self removeNotificaitons];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
