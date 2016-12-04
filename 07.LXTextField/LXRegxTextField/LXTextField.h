//
//  LXTextField.h
//  07.LXTextField
//
//  Created by longxiang on 16/11/13.
//  Copyright © 2016年 longxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,LXTextFieldType) {
    LXTextFieldType_userName  = 0,
    LXTextFieldType_pwd       = 1,
    LXTextFieldType_moblie    = 2,
    LXTextFieldType_phoneCode = 3,
    LXTextFieldType_imageCode = 4,
    LXTextFieldType_idCardNum = 5,
    LXTextFieldType_bankNum   = 6,
    LXTextFieldType_num       = 7,
    LXTextFieldType_money     = 8,
    LXTextFieldType_url       = 9,
    LXTextFieldType_mail      = 10
};

typedef NS_ENUM(NSInteger,LXTextCondition){
    LXTextCondition_notEmpty,      //数据是非空的
    LXTextCondition_verfiyOK,      //数据是合法的
};

/** 
   初始化指定类型的文本,可以选择性关联指定的textField,通过回调的方式判定按钮的状态
 ‘ + (instancetype)textFieldType:(LXTextFieldType)type right:(UIView*)rv left:(UIView*)lv;’
 ‘ + (void)blindTextFields:(NSArray*)textFields
                 condition:(LXBlindCondition)condition
                complement:(void(^)(BOOL isSuccess))complement;’
   下面属性部分分别指定了文本框需要设置的验证内容和属性,可以不用关注。在指定文本框类型的时候已经创建系统默认的属性
 */
@interface LXTextField : UITextField
/** 文本框输入完成所有文字进行正则校验*/
@property (strong, nonatomic) NSString* regx;
/** 文本框输入中指单个符校验*/
@property (strong, nonatomic) NSString* regexChar;
/** 文本框中分割符的正则,用于还原真实数据 realText */
@property (strong, nonatomic) NSString* regexSeperator;
//////////////////////////////////////////////////////////////////
/** 文本框中的分割符*/                                             //
@property (strong, nonatomic) NSString* seperator;              //
/** 文本框中分割符插入的位置: ege 185 8843 146X 对应 @[@3,@4,@4]✅*///
@property (strong, nonatomic) NSArray*  seperators;             //
//////////////////////////////////////////////////////////////////
/** 文本框进行长度校验*/
@property (assign, nonatomic) NSInteger maxLength;
/** 文本框字体大小设置*/
@property (strong, nonatomic) UIFont*   textfont;
/** 文本框占位字体大小*/
@property (strong, nonatomic) UIFont*   placeHolderFont;
/** 文本框占位颜色设置*/
@property (strong, nonatomic) UIColor*  placeHolderColor;
/** 文本框左边标题文字*/
@property (strong, nonatomic) NSString* leftTitle;
/** 文本框左边标题颜色*/
@property (strong, nonatomic) UIColor*  leftColor;
/** 文本框左边图片设置*/
@property (strong, nonatomic) NSString* leftImage;
/** 是否启用左边视图*/
@property (assign, nonatomic,getter=isLeftViewEnable)  BOOL leftViewEnable;
/** 是否启用右边视图,默认只有图片,短信,邮箱 文本框开默认开启右边视图*/
@property (assign, nonatomic,getter=isRightViewEnable) BOOL rightViewEnable;
/** 文本框文字是否采用 xxxx xxxx xxx分隔,目前仅适用于数字*/
@property (assign, nonatomic,getter=isSpaceEnable)     BOOL spaceEnable;
/** 是否开启正则校验*/
@property (assign, nonatomic,getter=isCheckEnable)     BOOL checkEnable;
/** ⚠️:用于父视图中关联所有不能为非空的textField,关联button的enable事件**/
@property (assign, nonatomic,getter=isAllowEmptyForBtnClick)   BOOL AllowEmptyForBtnClick;
/** 文本框正则校验错误是否震动*/
@property (assign, nonatomic,getter=isShakeEnable)     BOOL shakeEnbale;
/** 文本框结果是否校验成功*/
@property (assign, nonatomic,getter=isVerifyOK)        BOOL verifyOK;
/** 文本框校验错误信息*/
@property (strong, nonatomic) NSString* errorNote;
/** 文本框结束编辑之后,自动保存的真实数据*/
@property (strong, nonatomic) NSString* realText;
/** 文本框事件*/
@property (strong, nonatomic) void(^textFieldBeginEdit)(LXTextField* textField);
@property (strong, nonatomic) void(^textFieldChangeCharacter)(LXTextField* textField,BOOL changeSucess);
@property (strong, nonatomic) void(^textFieldEditChange)(LXTextField* textField);
@property (strong, nonatomic) void(^textFieldEditEnd)(LXTextField* textField);
@property (strong, nonatomic) void(^textFieldDidEndOnExit)(LXTextField* textField);
@property (strong, nonatomic) void(^setBtnStatus)(BOOL isEnable);

+ (instancetype)textFieldType:(LXTextFieldType)type right:(UIView*)rv left:(UIView*)lv;

/** 当绑定的文本发生变化后,设置btn的是否冻结的状态,‘建议对当前页面的所有文本绑定’*/
+ (void)blindTextFields:(NSArray *)textFields
             editChange:(void (^)(BOOL isEnable))setBtnStatus;

/** 当绑定的文本变化后,判断所有文本框是否都满足了该条件并将结果回调出来*/
+ (void)blindTextFields:(NSArray *)textFields
              condition:(LXTextCondition)condition
             complement:(void (^)(BOOL isSuccess))complement;


/** 以下为监听文本框输入的 五个状态 */
- (LXTextField*)textFieldBeginEdit:(void(^)(LXTextField* textField))textFieldBeginEdit;

- (LXTextField*)textFieldChangeCharacter:(void(^)(LXTextField* textField,BOOL sucess))textFieldChangeCharacter;

- (LXTextField*)textFieldEditChange:(void(^)(LXTextField* textField))textFieldEditChange;

- (LXTextField*)textFieldEditEnd:(void(^)(LXTextField* textField))textFieldEditEnd;

- (LXTextField*)textFieldDidEndOnExit:(void(^)(LXTextField* textField))textFieldDidEndOnExit;


@end


@interface LXTextField (RegularVaild)

- (BOOL)validateMaxLenght:(NSString*)text aString:(NSString*)aString;
- (BOOL)validateWholeCharacters:(NSString*)text ;

@end

@interface LXTextField (HandleSpaceText)

- (NSString*)getRealTextWithSperetorRegx:(NSString*)seRegx;

- (NSString*)separateTextWithSperator:(NSString*)seperator;

@end

@interface LXTextField (HandleMoneyText)

- (NSString*)getRealAmountHasDecimal:(BOOL)hasPot;
- (NSString*)seperatorMoneyWithPrefix:(NSString*)prefix sperator:(NSString*)seperator hasDecimal:(BOOL)hasPot;

- (NSString *)getCreditAmountWithTag:(int)tag;
- (NSString *)getRealCreditAmountWithTag:(int)tag;

@end

typedef NS_ENUM(NSInteger,ErrorType){
    ErrorType_shake              = 1,
    ErrorType_tips               = 2,
    ErrorType_charError          = 3,
    ErrorType_finalVadilateError = 4,
};

@interface LXTextField (handleErrorAnimation)

- (void)showErrorType:(ErrorType)errorType  notice:(NSString*)notice;

@end

