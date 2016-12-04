//
//  LXTextField.m
//  07.LXTextField
//
//  Created by longxiang on 16/11/13.
//  Copyright © 2016年 longxiang. All rights reserved.
//

/*************************宏定义*************************/
#define Color_dark_SperateLine          UIColorFromRGB(0xe5e5e5)
#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#endif
#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif
#ifndef LX_Rate
#define LX_Rate(lx_const) (lx_const * (SCREEN_WIDTH / 375.0))
#endif
#ifndef Font_SC
#define Font_SC(_size) [UIFont fontWithName:@"PingFang SC" size:LX_Rate(_size)]
#endif
#ifndef UIColorFromRGB
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#endif
/*************************宏定义*************************/

#import "LXTextField.h"
#import "PLMMsgView.h"  //刷新用,可以删除
@interface LXTextField()<UITextFieldDelegate>
{
    UIButton* _leftBtn;
    
    UIView*   _rightView;
    UIView*   _leftView;
    
    LXTextFieldType  _type;
    NSArray*  _typeKeys;      /**每个key在数组的下标与文本框的枚举值相同*/
    
    NSArray*  _textFields;
    
    UIView*   _speratorLineView;
}

/** 对所有绑定的文本框变化事件进行监听*/
@property (strong, nonatomic)void(^allTextChangeBlock)(LXTextField* textField);
/** 对指定的文本框变化事件进行监听*/
@property (strong, nonatomic)void(^optionTextChangeBlock)(LXTextField* textField);
/** 对指定的文本框结束编辑事件进行监听*/
@property (strong, nonatomic)void(^optionTextEndEditBlock)(LXTextField* textField);
@end

@implementation LXTextField
static NSDictionary* tf_dict = nil;
static NSBundle*   lx_bundle = nil;

+ (instancetype)textFieldType:(LXTextFieldType)type right:(UIView*)rv left:(UIView*)lv {
    return [[self alloc]initWithType:type right:rv left:lv];
}

- (instancetype)initWithType:(LXTextFieldType)type right:(UIView*)rv left:(UIView*)lv {
    if (self = [super init]) {
        
        _type       = type;
        _rightView  = rv;
        _leftView   = lv;
        
        [self initConfigData];
        
        [self initDefaultControls];
        
        [self setupDefaultStauts];
        
        [self setupDefaultStyles];
        
        [self setupUserDefineStyles];
        
        [self setupLeftView];
        
        [self setupRightView];
        
        [self setupEventsTarget];
        
        [self registerKVO];
        
        self.delegate = self;
    }
     return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bounds = CGRectMake(0, 0, SCREEN_WIDTH-LX_Rate(100), LX_Rate(53));
    }
    return self;
}

#pragma mark init config data
- (void)initConfigData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lx_bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]pathForResource:@"textFieldResuorce" ofType:@"bundle"]];
        NSString* path  = [lx_bundle pathForResource:@"textFieldConfig" ofType:@"json"];
        NSError* error = nil;
        NSString* jsonString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        tf_dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (error) NSAssert(nil, @"配置文件解析错误");
        
    });
    _typeKeys = tf_dict[@"typeKeys"];
}

- (void)initDefaultControls {
    
    CGFloat  margin = LX_Rate(20);
    CGFloat  height = LX_Rate(44);
    self.bounds = CGRectMake(0, 0,SCREEN_WIDTH - 2.0 * margin, height);
    _leftBtn = [[UIButton alloc]init];
    _leftBtn.userInteractionEnabled = NO;
    
    _speratorLineView = [[UIView alloc]init];
    _speratorLineView.backgroundColor = Color_dark_SperateLine;
    [self addSubview:_speratorLineView];
}


#pragma mark set properties
- (LXTextField*)textFieldBeginEdit:(void(^)(LXTextField* textField))textFieldBeginEdit{
    
    if (textFieldBeginEdit) {
        self.textFieldBeginEdit = textFieldBeginEdit;
    }
    return self;
}

- (LXTextField*)textFieldChangeCharacter:(void(^)(LXTextField* textField,BOOL sucess))textFieldChangeCharacter {
    if (textFieldChangeCharacter) {
        self.textFieldChangeCharacter = textFieldChangeCharacter;
    }
    return self;
}

- (LXTextField*)textFieldEditChange:(void(^)(LXTextField* textField))textFieldEditChange{
    if (textFieldEditChange) {
        self.textFieldEditChange = textFieldEditChange;
    }
    return self;
}

- (LXTextField*)textFieldEditEnd:(void(^)(LXTextField* textField))textFieldEditEnd  {
    if (textFieldEditEnd) {
        self.textFieldEditEnd = textFieldEditEnd;
    }
    return self;
}

- (LXTextField*)textFieldDidEndOnExit:(void(^)(LXTextField* textField))textFieldDidEndOnExit {
    if (textFieldDidEndOnExit) {
        self.textFieldDidEndOnExit = textFieldDidEndOnExit;
    }
    return self;
}

#pragma mark setup textField
- (void)setupDefaultStauts {

    /**
     1. 默认均不支持报错震动,且均不能为空
     2. Mobile,idCard,BankNum,Money均需要中间插入逗号,且不能未空
     */
    self.checkEnable    = YES;
    self.leftViewEnable = YES;
    self.AllowEmptyForBtnClick  = NO;
    self.shakeEnbale    = YES;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.rightViewMode = UITextFieldViewModeAlways;
    
    switch (_type) {
        case LXTextFieldType_moblie:
        case LXTextFieldType_idCardNum:
        case LXTextFieldType_bankNum:
        case LXTextFieldType_money:
            self.spaceEnable = YES;
            break;
        case LXTextFieldType_userName:
        case LXTextFieldType_pwd:
        case LXTextFieldType_phoneCode:
        case LXTextFieldType_imageCode:
        case LXTextFieldType_mail:
            self.spaceEnable  = NO;
            break;
        default:
            break;
    }
}

- (void)setupLeftView {
    
    if (_leftView) {
        self.leftView = _leftView;
        return;
    }
    
    if (self.leftViewEnable == NO)     return;
    
    //使用系统默认的leftBtn
    if (!_leftTitle) _leftTitle = tf_dict[@"leftTitle"][_typeKeys[_type]];
    if (!_leftImage) _leftImage = tf_dict[@"leftImageName"][_typeKeys[_type]];
    UIColor * color = _leftColor == nil?[UIColor blackColor]:_leftColor;
    UIFont*   font  = _textfont  == nil? Font_SC(15): _textfont;
    
    
    NSString* path = [NSString stringWithFormat:@"%@%@%@",[lx_bundle bundlePath],@"/textFieldImage/",_leftImage];
    [_leftBtn setImage:[UIImage imageNamed:path] forState:UIControlStateNormal];
    [_leftBtn setTitle:[NSString stringWithFormat:@"%@ : ",_leftTitle] forState:UIControlStateNormal];
    [_leftBtn setTitleColor:color forState:UIControlStateNormal];
    _leftBtn.titleLabel.font = font;
    [_leftBtn sizeToFit];
    _leftBtn.bounds = CGRectMake(0, 0, _leftBtn.bounds.size.width+15, _leftBtn.bounds.size.height);
    self.leftView = _leftBtn;
    _leftBtn.contentHorizontalAlignment = NSTextAlignmentLeft;
    _leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    _leftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    
}

- (void)setupRightView {
 
    if (_rightView)   {
        self.rightView = _rightView;
    }
    
    if (self.rightViewEnable == NO)  return;  //用于刷新右视图
   
}

- (void)setupDefaultStyles {
    
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.returnKeyType   = UIReturnKeyNext;
    self.keyboardType    = UIKeyboardTypeDefault;
    //self.borderStyle     = UITextBorderStyleBezel;
    
    self.textColor = [UIColor grayColor];
    NSString* placeHd = tf_dict[@"placeHolder"][_typeKeys[_type]];
    self.placeholder = placeHd;
    
    if (_type == LXTextFieldType_pwd)  self.secureTextEntry = YES;
    
    /** 关闭联想记忆,防止选择字符串出现bug*/
    self.autocorrectionType  = UITextAutocorrectionTypeNo;
    switch (_type) {
        case LXTextFieldType_moblie:
        case LXTextFieldType_idCardNum:
        case LXTextFieldType_bankNum:
        case LXTextFieldType_money: //这里仅限值不能输入特殊符号,实际最后结果可以拼接特殊符号
            self.keyboardType = UIKeyboardTypeDefault;
            break;
        case LXTextFieldType_userName:
        case LXTextFieldType_pwd:
        case LXTextFieldType_phoneCode:
        case LXTextFieldType_imageCode:
            self.keyboardType = UIKeyboardTypeDefault;
            break;
        case LXTextFieldType_mail:
            self.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        default:
            break;
    }
    
}

- (void)setupEventsTarget {
    [self addTarget:self action:@selector(lxRegx_textFieldEditingDidDegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(lxRegx_textFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [self addTarget:self action:@selector(lxRegx_textFieldDidChangeEdit:) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(lxRegx_textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)setupUserDefineStyles {
    if (_placeHolderColor)  [self setValue:_placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    if (_placeHolderFont)  [self setValue:_placeHolderFont forKeyPath:@"_placeholderLabel.font"];
}

#pragma mark security actions
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_type != LXTextFieldType_pwd) {
        return [super canPerformAction:action withSender:sender];
    }
    if (action == @selector(paste:))
        return NO;
    if (action == @selector(select:))
        return NO;
    if (action == @selector(selectAll:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}


#pragma mark edit events

- (void)lxRegx_textFieldEditingDidDegin:(LXTextField*)textField {
    if (_type == LXTextFieldType_money) self.text = nil;
    if (self.textFieldBeginEdit)  self.textFieldBeginEdit(textField);
}

- (void)lxRegx_textFieldDidChangeEdit:(LXTextField*)textField {
    
    if (LXTextFieldType_money == _type){
       self.text = [self seperatorMoneyWithPrefix:nil sperator:nil hasDecimal:NO];
    }else{
        if (self.isSpaceEnable) self.text = [self separateTextWithSperator:nil];
    }
    
    if (self.textFieldEditChange)  self.textFieldEditChange(textField);
    
    if (self.allTextChangeBlock)  self.allTextChangeBlock(textField);
    
    if (self.optionTextChangeBlock)  self.optionTextChangeBlock(textField);
}

- (void)lxRegx_textFieldEditingDidEnd:(LXTextField*)textField {
    /** 1.将特殊文本还原*/
    if (LXTextFieldType_money == _type) {
        self.realText = [self getRealCreditAmountWithTag:0];
    }else{
        self.realText = [self getRealTextWithSperetorRegx:nil];
    }
    
    /** 2.对原来的数据进行还原 */
    if (self.isCheckEnable) [self validateWholeCharacters:self.realText];
    
    if (self.textFieldEditEnd)  self.textFieldEditEnd(textField);
    
    NSString* valiateDes = self.verifyOK? @"" : tf_dict[@"notice"][_typeKeys[_type]];
    self.errorNote = valiateDes;
    if (self.isShakeEnable && self.verifyOK == NO && self.text.length != 0) {
        [self showErrorType:ErrorType_finalVadilateError notice:valiateDes];
    }
#warning to do bounceNote
    if (self.optionTextEndEditBlock)  self.optionTextEndEditBlock(textField);
    
}

- (void)lxRegx_textFieldDidEndOnExit:(LXTextField*)textField {
 
    [self lxRegx_textFieldEditingDidEnd:textField];
    
    if (self.textFieldDidEndOnExit)  self.textFieldDidEndOnExit(textField);
    
    if (self.returnKeyType == UIReturnKeyDone) {
       [self endEditing:YES];
    }
}

- (BOOL)textField:(LXTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //2.do not check
    if (self.checkEnable == NO)  return YES;
    
    //3.click textField cleanButton
    if ([string isEqualToString:@""])   return YES;
    
    //4.keyboard returnKey
    if ([string isEqualToString:@"\n"])  return YES;
    
    //6.caculate real lenght for num text
    NSString* realStr = nil;
    if (LXTextFieldType_money == _type) {
        realStr = [self getRealCreditAmountWithTag:0];
    }else{
        realStr = [self getRealTextWithSperetorRegx:nil];
    }
    
    //7.maxLength and aString regx
    BOOL isvaild  = [self validateMaxLenght:realStr aString:string];
    
    //8.回调输入的字符的结果是否合法
    if (self.textFieldChangeCharacter) self.textFieldChangeCharacter(textField,isvaild);
    if (isvaild == NO) {
        if (self.isShakeEnable && self.verifyOK == NO && self.text.length != 0) {
            [self showErrorType:ErrorType_charError notice:@"您输入的字符不合法"];
        }
    }
    return isvaild;

}

#pragma mark blind events
+ (void)blindTextFields:(NSArray *)textFields editChange:(void (^)(BOOL))setbtnState {
   
    /** 1.根据绑定的textFields顺序设置returnKeyType*/
    for (int i =0; i<textFields.count; i++) {
        //未达到最后一个
        LXTextField* textField = textFields[i];
        if (i<textFields.count - 1 && textField.keyboardType != UIKeyboardTypeNumberPad) {
            textField.returnKeyType = UIReturnKeyNext;
        }
        if (i == textFields.count - 1 && textField.keyboardType != UIKeyboardTypeNumberPad) {
            textField.returnKeyType = UIReturnKeyDone;
        }
    }
    
    /** 2.根据点击returnKeyType的回调事件,决定下一响应者*/
    for (int i =0; i<textFields.count; i++) {
        LXTextField* textField = textFields[i];
        textField.textFieldDidEndOnExit = ^(LXTextField* textField) {
            if (textField.returnKeyType == UIReturnKeyDone||
                textField.returnKeyType == UIReturnKeyJoin||
                textField.returnKeyType == UIReturnKeyGo) {
                [textField endEditing:YES];
            }else if(textField.returnKeyType == UIReturnKeyNext){
                if (i < textFields.count-1) {
                    LXTextField* nextTextField = textFields[i+1];
                    [nextTextField becomeFirstResponder];
                }
            }
        };
    }
    
    /** 3.对每个textField的change事件进行逐一监听,判断指定的文本是否满足非空条件并回调出去*/
    __block BOOL isAllTextFieldNotEmpty = YES;
    for (int i =0; i<textFields.count; i++) {
        LXTextField* textField = textFields[i];
        textField.allTextChangeBlock = ^(LXTextField* textField) {
            for (LXTextField* tempTextField in textFields) {
                if (tempTextField.text.length == 0 && textField.isAllowEmptyForBtnClick == NO) {
                    isAllTextFieldNotEmpty = NO;
                    break;
                }
            }
            setbtnState(isAllTextFieldNotEmpty);
        };
    }
}

+ (void)blindTextFields:(NSArray *)textFields condition:(LXTextCondition)condition complement:(void (^)(BOOL success))complement {
    
    /** 1.绑定的文本框是否全都不为空 */
    if (condition == LXTextCondition_notEmpty ) {
        __block BOOL isAllTextFieldNotEmpty = YES;
        for (int i =0; i<textFields.count; i++) {
            LXTextField* textField = textFields[i];
            textField.optionTextChangeBlock = ^(LXTextField* textField) {
                for (LXTextField* tempTextField in textFields) {
                    if (tempTextField.text.length == 0 && textField.isAllowEmptyForBtnClick == NO) {
                        isAllTextFieldNotEmpty = NO;
                        break;
                    }
                }
                complement(isAllTextFieldNotEmpty);
            };
        }
        return;
    }
    /** 2.绑定的文本框是否全部校验成功*/
    if (condition == LXTextCondition_verfiyOK ) {
        __block BOOL isAllTextFieldNotEmpty = YES;
        for (int i =0; i<textFields.count; i++) {
            LXTextField* textField = textFields[i];
            textField.optionTextEndEditBlock = ^(LXTextField* textField) {
                for (LXTextField* tempTextField in textFields) {
                    if (tempTextField.verifyOK == NO) {
                        break;
                    }
                }
                complement(isAllTextFieldNotEmpty);
            };
        }
        return;
    }
}

#pragma mark kvo events
- (void)registerKVO {
    for (NSString* keyPath in [self keyPaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)unRegisterKVO {
    for (NSString* keyPath in [self keyPaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSSet*)keyPaths {
    return [NSSet setWithObjects:@"textfont",@"placeHolderColor",@"placeHolderFont",@"leftTitle",@"leftColor",@"leftImage",@"rightViewEnable",@"leftViewEnable", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
      [self setupUserDefineStyles];
      [_leftBtn setImage:[UIImage imageNamed:self.leftImage] forState:UIControlStateNormal];
      [self setupRightView];
}

- (void)dealloc {
    [self unRegisterKVO];
}

#pragma mark layout/apperance
/*
- (void)drawRect:(CGRect)rect {
   
}

- (void)drawTextInRect:(CGRect)rect {
   
}
*/

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    
    if (_type == LXTextFieldType_imageCode ||
        _type == LXTextFieldType_phoneCode
        ){
        return CGRectMake(bounds.size.width - LX_Rate(30),bounds.size.height*0.33, LX_Rate(20), LX_Rate(20));
   
        }
    return CGRectMake(bounds.size.width- LX_Rate(20),bounds.size.height*0.33, LX_Rate(20), LX_Rate(20));
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _speratorLineView.frame = CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1);
}

@end


@implementation LXTextField (RegularVaild)

- (BOOL)validateMaxLenght:(NSString*)text {
    if (self.isCheckEnable == NO)  return YES;
    if (text.length > 0) {
        NSInteger maxLength = (self.maxLength >0)?self.maxLength:[tf_dict[@"maxLength"][_typeKeys[_type]] integerValue];
        if (text.length > maxLength-1) return NO;
    }
    return YES;
}

- (BOOL)validateMaxLenght:(NSString*)text aString:(NSString*)aString {
    if (self.isCheckEnable == NO)  return YES;
    if (text.length > 0) {
        NSInteger maxLength = (self.maxLength >0)?self.maxLength:[tf_dict[@"maxLength"][_typeKeys[_type]] integerValue];
        if (text.length > maxLength-1) return NO;
    }
    BOOL result = YES;
    NSError* error = nil;
    NSString* charRegx = (self.regexChar)?self.regexChar:tf_dict[@"charRegx"][_typeKeys[_type]];
    NSRegularExpression* regx = [[NSRegularExpression alloc]initWithPattern:charRegx options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) result = ([regx numberOfMatchesInString:aString options:NSMatchingAnchored range:NSMakeRange(0, aString.length)]>0);
    return result;
}

- (BOOL)validateWholeCharacters:(NSString*)text  {
    if (self.isCheckEnable == NO)  {
        self.verifyOK = YES;
        return YES;
    }
    NSString* regx = self.regx?self.regx : tf_dict[@"regx"][_typeKeys[_type]];
    BOOL result = YES;
    
    NSPredicate* valiatePre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regx];
    result = [valiatePre evaluateWithObject:self.realText];
    
    self.verifyOK = result;
    return result;
}

@end

@implementation LXTextField (HandleSpaceText)

- (NSString*)getRealTextWithSperetorRegx:(NSString*)seRegx {
    
    if (self.spaceEnable == NO)  return [self.text copy];
    if ([self.text isEqualToString:@""])  return @"";
    if (self.regexSeperator)  seRegx = self.regexSeperator;
    seRegx = seRegx ? seRegx :tf_dict[@"seperatorRegx"][_typeKeys[_type]];
    NSMutableString* mutableStr = [self.text mutableCopy];
    [mutableStr replaceOccurrencesOfString:seRegx withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, mutableStr.length)];
    NSString* realStr = [mutableStr copy];
    
    return realStr;
}

- (NSString*)separateTextWithSperator:(NSString*)seperator {
    
    if (self.spaceEnable == NO)  return [self.text copy];
    if (self.regexSeperator)  seperator = self.seperator;
    seperator = seperator ? seperator :tf_dict[@"seperator"][_typeKeys[_type]];
    NSArray* seperators = self.seperators?self.seperators:tf_dict[@"seperators"][_typeKeys[_type]];
    NSMutableString* mutableStr = [[self getRealTextWithSperetorRegx:nil] mutableCopy];
    NSInteger index = 0;
    for (int i = 0; i<seperators.count; i++) {
        index += [seperators[i] integerValue];
        if ((index+i*(seperator.length)) >= mutableStr.length) break;
        [mutableStr insertString:seperator atIndex:(index+i*seperator.length)];
    }
    return [mutableStr copy];
}

@end

@implementation LXTextField (HandleMoneyText)

- (NSString *)getCreditAmountWithTag:(int)tag {
    if ([self.text isEqualToString:@""])   return @"";
    NSMutableString* mutableStr = [self.text mutableCopy];
    if  ([mutableStr containsString:@"¥"]){
        [mutableStr replaceOccurrencesOfString:@"¥" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mutableStr.length-1)];
    }
    if  ([mutableStr containsString:@","]){
        [mutableStr replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mutableStr.length-1)];
    }
    if  ([mutableStr containsString:@"."]==NO){
        [mutableStr appendString:@".00"];
    }
    NSRange sperateRange = [mutableStr rangeOfString:@"."];
    NSMutableString* rightStr  = [[mutableStr substringToIndex:sperateRange.location] mutableCopy];
    
    NSString* leftStr= [mutableStr substringFromIndex:sperateRange.location+1];
    if (leftStr.length < 2) leftStr = [@"00" mutableCopy];
    
    NSString* tagStr = (tag == 0)?@"¥":@"$";
    int count = (int)rightStr.length/3;
    int mod   = rightStr.length%3;
    if(mod > 0){
        for(int index = 1;index <= count;index++){
            [rightStr insertString:@"," atIndex:rightStr.length-1-(index*3-1+(index-1))];
        }
    }else{
        for(int index = 1;index <= count-1;index++){
            [rightStr insertString:@"," atIndex:rightStr.length-1-(index*3-1+(index-1))];
        }
    }
    NSString* finalStr = [NSString stringWithFormat:@"%@%@.%@",tagStr,rightStr,leftStr];
    //    NSLog(@"%@",finalStr);
    return finalStr;
}

- (NSString *)getRealCreditAmountWithTag:(int)tag {
    
    if (self.isSpaceEnable == NO)  return self.text;
    if (LXTextFieldType_money != _type)  return self.text;
    NSString* tagStr = (tag == 0)?@"¥":@"$";
    NSMutableString* mutableStr = [self.text mutableCopy];
    if  ([mutableStr containsString:@"¥"]){
        [mutableStr replaceOccurrencesOfString:tagStr withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mutableStr.length-1)];
    }
    if  ([mutableStr containsString:@","]){
        [mutableStr replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mutableStr.length-1)];
    }
    if  ([mutableStr containsString:@"."]){
        NSInteger locaiton = [mutableStr rangeOfString:@"."].location;
        [mutableStr replaceCharactersInRange:NSMakeRange(locaiton, mutableStr.length-locaiton) withString:@""];
    }
    
    return [mutableStr copy];
}

- (NSString*)getRealAmountHasDecimal:(BOOL)hasPot {
    NSMutableString * mutableStr = [self.text mutableCopy];
    [mutableStr replaceOccurrencesOfString:@"[$¥,]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, mutableStr.length)];
    if (mutableStr.length == 0)  return nil;
    
    NSMutableString  *left,*pot,*right;
    NSInteger potLocaiton;
    pot = [mutableStr containsString:@"."]?[@"." mutableCopy ]:nil;
    if (pot) {
        potLocaiton = [mutableStr rangeOfString:pot].location;
        left   = [[mutableStr substringToIndex:potLocaiton] mutableCopy];
        right  = [[mutableStr substringFromIndex:potLocaiton] mutableCopy];
        if (right.length == 0) {
            [right appendString:@"00"];
        }else {
            int     ri  = [right intValue];
            CGFloat rf  = ri/(10*right.length)* 0.f;
            right       = [NSMutableString stringWithFormat:@"%0.2f",rf];
        }
        if (left.length == 0)left = [@"0" mutableCopy];
    }
    return hasPot?[NSString stringWithFormat:@"%@,%@,%@",left,pot,right] : [mutableStr copy];
}


- (NSString*)seperatorMoneyWithPrefix:(NSString*)prefix sperator:(NSString*)seperator hasDecimal:(BOOL)hasPot {
    
    NSMutableString* mutableStr = [[self getRealAmountHasDecimal:hasPot] mutableCopy];
    NSMutableString  *left = [NSMutableString string];
    NSMutableString *right = [NSMutableString string];
    if (hasPot) {
        NSInteger potLocaiton = [mutableStr rangeOfString:@"."].location;
        left  = [[mutableStr substringToIndex:potLocaiton] mutableCopy];
        right = [[mutableStr substringFromIndex:potLocaiton+1] mutableCopy];
    }else{
        left = [mutableStr copy];
    }
    
    if (prefix == nil) prefix = @"¥";
    if (seperator == nil) seperator = @",";
    NSInteger space = 3;
    NSInteger mod = left.length % space;
    const char *ch = [left UTF8String];
    NSMutableString* tempString = [NSMutableString string];
    int j=0;
    for (int i = 0; i<left.length; i++) {
        [tempString appendString:[NSString stringWithFormat:@"%c",ch[i]]];
        j++;
        if (i == left.length-1 && mod == 0) {
            continue;
        }
        if (j/space == 1 ) {
            [tempString appendString:seperator];
            j = 0;
        }
        
    }
    return [NSString stringWithFormat:@"%@%@%@",prefix,tempString,hasPot?right:@""];
}

@end


@implementation LXTextField (handleErrorAnimation)

- (void)showErrorType:(ErrorType)errorType notice:(NSString*)notice{
    __weak typeof(*&self) weaKSelf = self;
    UIColor* errorColor = [UIColor redColor];
    weaKSelf.textColor = errorColor;
    switch (errorType) {
        case ErrorType_shake:
            [self shakeAnimation:0.1];
            break;
        case ErrorType_tips:
            [self shakeAnimation:0.1];
            break;
        case ErrorType_charError:
            [PLMMsgView showMsg:notice onView:nil offsetY:20];
           // [self shakeAnimation:0.1];
            break;
        case ErrorType_finalVadilateError:
            [PLMMsgView showMsg:notice onView:nil offsetY:20];
          //  [self shakeAnimation:0.1];
            break;
        default:
            break;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weaKSelf.layer removeAllAnimations];
        weaKSelf.textColor = [UIColor blackColor];
        [self setNeedsDisplay];
    });
}

- (void)shakeAnimation:(NSTimeInterval)duration {
    if (self.isShakeEnable == NO) return;
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.fromValue = @0;
    shake.toValue = @5;
    shake.repeatCount  = MAXFLOAT;
    shake.autoreverses = YES;
    shake.duration = duration;
    [self.layer addAnimation:shake forKey:@"shake"];
}

- (void)showErrorTips{
    
}

@end
