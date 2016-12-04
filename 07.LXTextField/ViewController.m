//
//  ViewController.m
//  07.LXTextField
//
//  Created by longxiang on 16/11/13.
//  Copyright © 2016年 longxiang. All rights reserved.
//

#import "ViewController.h"
#import "LXTextField.h"
#import "UITextField+CHTHealper.h"
@interface ViewController ()
{
  
    UIButton*     nextStepBtn;
    UIButton*     phoneCodeBtn;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //根据type创建10种类型的文本框并布局
    CGFloat orignY  = 100;
    CGFloat centerX = self.view.bounds.size.width*0.5;
    NSMutableArray* allTextFields = [NSMutableArray array];
    NSMutableArray* moblieAndPwdTFs  = [NSMutableArray array];
    LXTextField* tempTF;
    for (int index = 0;index < 10 ; index++) {
        tempTF = [LXTextField textFieldType:index  right:nil left:nil];
        tempTF.center = CGPointMake(centerX, orignY);
        orignY+= 50;
        [self.view addSubview:tempTF];
        [allTextFields addObject:tempTF];
        if (index == LXTextFieldType_moblie ||
            index == LXTextFieldType_pwd ) {
            [moblieAndPwdTFs addObject:tempTF];
        }
    }
    
    [self setupBtnsCenterX:centerX orignY:orignY];
    
    /******************************文本框事件绑定*********************************/
    //case1: 判断指定文本非空后btn显示为可点击,同时自动添加文本returnKeyType
    [LXTextField blindTextFields:allTextFields editChange:^(BOOL isEnable) {
        nextStepBtn.enabled = isEnable;
    }];
    
    //case2: 自动校验所有指定的文本正则验证OK后  btn切换为可点击状态
    [LXTextField blindTextFields:allTextFields condition:LXTextCondition_verfiyOK complement:^(BOOL isSuccess) {
        nextStepBtn.enabled = isSuccess;
    }];
    
    //case3: 指定需要验证的文本框,和需要验证类型(如非空,字符格式校验),并实时回调验证的结果
    [LXTextField blindTextFields:moblieAndPwdTFs condition:LXTextCondition_verfiyOK  complement:^(BOOL isSuccess) {
        if (isSuccess && phoneCodeBtn.enabled == NO) {
            phoneCodeBtn.enabled = YES;
        }
    }];
    
    //case4: 对单个文本框 开始,正在,结束,退出 编辑,进行统一的回调处理
    LXTextField* mobileTF = [LXTextField textFieldType:LXTextFieldType_moblie right:nil left:nil];
    mobileTF.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 25);
    [self.view addSubview:mobileTF];
    [[[[[mobileTF textFieldBeginEdit:^(LXTextField *textField) {
        NSLog(@"textFieldBeginEdit:%@",textField.text);
    }] textFieldChangeCharacter:^(LXTextField *textField, BOOL sucess) {
        NSLog(@"textFieldChangeCharacter:%@",textField.text);
    }] textFieldEditChange:^(LXTextField *textField) {
          NSLog(@"textFieldEditChange:%@",textField.text);
    }] textFieldEditEnd:^(LXTextField *textField) {
          NSLog(@"textFieldEditEnd:%@",textField.text);
    }] textFieldDidEndOnExit:^(LXTextField *textField) {
          NSLog(@"textFieldEditChange:%@",textField.text);
    }];
    
    //case5: 对文本框的校验为空进行取消
    mobileTF.checkEnable = NO;
    mobileTF.AllowEmptyForBtnClick = NO;
    mobileTF.rightView = [UIView new];
    
    //case6: 替换某个文本的校验方式
    mobileTF.regx = @"^1[3|4|5|7|8]\\d{8}$";
    mobileTF.regexChar = @"[0~9]";
    mobileTF.maxLength = 11; //注意设置最大长度范围不能超过regx匹配的最大范围。
    
    //case7: 自定义设置某个文本中间的空白位置
    mobileTF.seperator = @" ";
    mobileTF.seperators = @[@3,@4,@4]; //表示需要将文本截成3,4,4段,中间用空格隔开。
    
    //case8: 错误提示,分别为单个字符输入非法提示, 输入完成校验提示,可以修改配置。
    /** - (void)showErrorType:(ErrorType)errorType  notice:(NSString*)notice; */
    
    //case9: 针对项目需求可以在 textFieldResuorce.bundle/textFieldConfig.json中的配置文件中进行统一的修改。
    
}

- (void)setupBtnsCenterX:(CGFloat)centerX orignY:(CGFloat)orignY {
 
    centerX = self.view.bounds.size.width* 0.25;
    nextStepBtn  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
    
    [nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextStepBtn setTitle:@"下一步冻结" forState:UIControlStateDisabled];
    [nextStepBtn setBackgroundImage:[self imageWithRect:nextStepBtn.bounds] forState:UIControlStateNormal];
    nextStepBtn.center = CGPointMake(centerX, orignY+20);
    nextStepBtn.enabled = NO;
    nextStepBtn.layer.cornerRadius = 10;
    nextStepBtn.layer.masksToBounds = YES;
    [self.view addSubview:nextStepBtn];
    
    centerX = self.view.bounds.size.width* 0.75;
    phoneCodeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
  
    phoneCodeBtn.enabled = NO;
    [phoneCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [phoneCodeBtn setTitle:@"获取验证码冻结" forState:UIControlStateDisabled];
    phoneCodeBtn.center = CGPointMake(centerX, orignY+20);
    phoneCodeBtn.enabled = NO;
    phoneCodeBtn.layer.cornerRadius = 10;
    phoneCodeBtn.layer.masksToBounds = YES;
    [phoneCodeBtn setBackgroundImage:[self imageWithRect:nextStepBtn.bounds] forState:UIControlStateNormal];
    [self.view addSubview:phoneCodeBtn];
 
}

- (UIImage*)imageWithRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
    
    [[UIColor colorWithWhite:0 alpha:1] set];
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    [path fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
