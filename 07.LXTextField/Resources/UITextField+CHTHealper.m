//
//  UITextField+CHTPositionChange.m
//  CHTTextFieldHealper
//
//  Created by risenb_mac on 16/8/17.
//  Copyright © 2016年 risenb_mac. All rights reserved.
//

#import "UITextField+CHTHealper.h"
#import <objc/runtime.h>

static char canMoveKey;
static char moveViewKey;
static char heightToKeyboardKey;
static char initialYKey;
static char tapGestureKey;
static char keyboardYKey;
static char totalHeightKey;
static char keyboardHeightKey;
static char hasContentOffsetKey;

@implementation UITextField (CHTHealper)
@dynamic canMove;
@dynamic moveView;
@dynamic heightToKeyboard;
@dynamic initialY;
@dynamic tapGesture;
@dynamic keyboardY;
@dynamic totalHeight;
@dynamic keyboardHeight;
@dynamic hasContentOffset;


/**
 1。在程序启动前,当类被加载到内存中的时候,开辟一个一次性任务,将UITextField的initWithFrame方法进行对象。
 之所以选择initWithFrame方法,是因为UITextField不管调用哪个方法最终都会调initWithFrame,initWithCoder也不例外。
 2.方法交换的思路,主要是利用runTime构建两个方法选择器。
 
 */
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL systemSel = @selector(initWithFrame:);
        SEL mySel = @selector(setupInitWithFrame:);
        [self exchangeSystemSel:systemSel bySel:mySel];
        
        SEL systemSel2 = @selector(becomeFirstResponder);
        SEL mySel2 = @selector(newBecomeFirstResponder);
        [self exchangeSystemSel:systemSel2 bySel:mySel2];
        
        SEL systemSel3 = @selector(resignFirstResponder);
        SEL mySel3 = @selector(newResignFirstResponder);
        [self exchangeSystemSel:systemSel3 bySel:mySel3];
        
        SEL systemSel4 = @selector(initWithCoder:);
        SEL mySel4 = @selector(setupInitWithCoder:);
        [self exchangeSystemSel:systemSel4 bySel:mySel4];
    });
    [super load];
}

// 交换方法
+ (void)exchangeSystemSel:(SEL)systemSel bySel:(SEL)mySel {
    Method systemMethod = class_getInstanceMethod([self class], systemSel);
    Method myMethod = class_getInstanceMethod([self class], mySel);
    //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
    /**
     cls
     The class to which to add a method.
     name
     A selector that specifies the name of the method being added.
     imp
     A function which is the implementation of the new method. The function must take at least two arguments—self and _cmd.
     types
     An array of characters that describe the types of the arguments to the method. For possible values, see Objective-C Runtime Programming Guide > Type Encodings. Since the function must take at least two arguments—self and _cmd, the second and third characters must be “@:” (the first character is the return type).
     
     self为方法的类, systemSel为方法选标示, myMethod为方法指针和方法的实现体部分，myMethod的typeEncoding代表 获取方法参数的编码类型.
     
     */
    
    /** 2.看有无实现该方法,像系统方法的实现体换成我们自定义的方法*/
    BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(myMethod), method_getTypeEncoding(myMethod));
    if (isAdd) {
        //如果成功，说明类中不存在这个方法的实现
        //将被交换方法的实现替换到这个并不存在的实现
        class_replaceMethod(self, mySel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        //否则，交换两个方法的实现
        method_exchangeImplementations(systemMethod, myMethod);
    }
}

/** 第一次调用为原来的方法*/
- (instancetype)setupInitWithCoder:(NSCoder *)aDecoder {
    [self setup];
    return [self setupInitWithCoder:aDecoder];
}

- (instancetype)setupInitWithFrame:(CGRect)frame {
    [self setup];
    return [self setupInitWithFrame:frame];
}

- (void)setup {
    self.heightToKeyboard = 10;
    self.canMove = YES;
    self.keyboardY = 0;
    self.totalHeight = 0;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
}

- (void)showAction:(NSNotification *)sender {
//    NSLog(@"%@", sender);
    if (!self.canMove) {
        return;
    }
    self.keyboardY = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.keyboardHeight = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self keyboardDidShow];
}

- (void)hideAction:(NSNotification *)sender {
    if (!self.canMove || self.keyboardY == 0) {
        return;
    }
    [self hideKeyBoard:0.25];
}

- (void)keyboardDidShow {
    if (self.keyboardHeight == 0) {
        return;
    }
    //  将自视图 Field的左上角定顶点转换为KeyWindow的坐标中的Y
    CGFloat fieldYInWindow = [self convertPoint:self.bounds.origin toView:[UIApplication sharedApplication].keyWindow].y;
    CGFloat height = (fieldYInWindow + self.heightToKeyboard + self.frame.size.height) - self.keyboardY;
    CGFloat moveHeight = height > 0 ? height : 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.hasContentOffset) {
            UIScrollView *scrollView = (UIScrollView *)self.moveView;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + moveHeight);
        } else {
            CGRect rect = self.moveView.frame;
            self.initialY = rect.origin.y;
            rect.origin.y -= moveHeight;
            self.moveView.frame = rect;
        }
        self.totalHeight += moveHeight;
    }];
}

- (void)hideKeyBoard:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        if (self.hasContentOffset) {
            UIScrollView *scrollView = (UIScrollView *)self.moveView;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - self.totalHeight);
        } else {
            CGRect rect = self.moveView.frame;
            rect.origin.y += self.totalHeight;
            self.moveView.frame = rect;
        }
        self.totalHeight = 0;
    }];
}

- (BOOL)newBecomeFirstResponder {
    if (self.moveView == nil) {
        self.moveView = [self viewController].view;
    }
    if (![self.moveView.gestureRecognizers containsObject:self.tapGesture]) {
        [self.moveView addGestureRecognizer:self.tapGesture];
    }
    
    //如果self是第一响应者,如果self不能够移动
    if ([self isFirstResponder] || !self.canMove) {
        
        return [self newBecomeFirstResponder];
//        return YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAction:) name:UIKeyboardWillHideNotification object:nil];
//    return YES;
    return [self newBecomeFirstResponder];
}

- (BOOL)newResignFirstResponder {
    if ([self.moveView.gestureRecognizers containsObject:self.tapGesture]) {
        [self.moveView removeGestureRecognizer:self.tapGesture];
    }
    if (!self.canMove) {
        return [self newResignFirstResponder];
    }
    BOOL result = [self newResignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self hideKeyBoard:0];
    return result;
}

- (void)tapAction {
    [[self viewController].view endEditing:YES];
}

- (UIViewController *)viewController {
    UIView *next = self;
    while (1) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
        next = next.superview;
    }
    return nil;
}

- (void)setCanMove:(BOOL)canMove {
    objc_setAssociatedObject(self, &canMoveKey, @(canMove), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)canMove {
    return [objc_getAssociatedObject(self, &canMoveKey) boolValue];
}

- (void)setHeightToKeyboard:(CGFloat)heightToKeyboard {
    objc_setAssociatedObject(self, &heightToKeyboardKey, @(heightToKeyboard), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)heightToKeyboard {
    return [objc_getAssociatedObject(self, &heightToKeyboardKey) floatValue];
}

- (void)setMoveView:(UIView *)moveView {
    self.hasContentOffset = NO;
    if ([moveView isKindOfClass:[UIScrollView class]]) {
        self.hasContentOffset = YES;
    }
    
    objc_setAssociatedObject(self, &moveViewKey, moveView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)moveView {
    return objc_getAssociatedObject(self, &moveViewKey);
}

- (void)setInitialY:(CGFloat)initialY {
    objc_setAssociatedObject(self, &initialYKey, @(initialY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)initialY {
    return [objc_getAssociatedObject(self, &initialYKey) floatValue];
}

- (void)setTapGesture:(UITapGestureRecognizer *)tapGesture {
    objc_setAssociatedObject(self, &tapGestureKey, tapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITapGestureRecognizer *)tapGesture {
    return objc_getAssociatedObject(self, &tapGestureKey);
}

- (void)setKeyboardY:(CGFloat)keyboardY {
    objc_setAssociatedObject(self, &keyboardYKey, @(keyboardY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)keyboardY {
    return [objc_getAssociatedObject(self, &keyboardYKey) floatValue];
}

- (void)setTotalHeight:(CGFloat)totalHeight {
    objc_setAssociatedObject(self, &totalHeightKey, @(totalHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)totalHeight {
    return [objc_getAssociatedObject(self, &totalHeightKey) floatValue];
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    objc_setAssociatedObject(self, &keyboardHeightKey, @(keyboardHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)keyboardHeight {
    return [objc_getAssociatedObject(self, &keyboardHeightKey) floatValue];
}

- (void)setHasContentOffset:(BOOL)hasContentOffset {
    objc_setAssociatedObject(self, &hasContentOffsetKey, @(hasContentOffset), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hasContentOffset {
    return [objc_getAssociatedObject(self, &hasContentOffsetKey) boolValue];
}

@end
