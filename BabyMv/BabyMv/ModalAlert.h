/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface ModalAlert : NSObject
+ (NSString *) ask: (NSString *) question withTextPrompt: (NSString *) prompt;
+ (NSUInteger) ask: (NSString *) question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons;
+ (NSString *) ask: (NSString *) question withText: (NSString *) text;
+ (void) sayold: (id)formatstring,...;
+ (BOOL) ask: (id)formatstring,...;
+ (BOOL) confirm: (id)formatstring,...;
+ (void) say: (NSString *) formatstring;
+ (void) say:(NSString *) formatstring withButtonTitles:(NSString *) buttonTitles;
@end

@interface UIBlockAlertView : UIAlertView<UIAlertViewDelegate> {
    void (^_block)(UIBlockAlertView*, NSInteger);
    void (^_boolBlock)(bool);
    NSInteger _type;
    UITextField* _inputfield;
}

@property(nonatomic,assign) UIAlertViewStyle alertViewStyle;
- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtons: (NSArray *) buttons andDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal;

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtons: (NSArray *) buttons andDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal;

+ (void)say:(NSString *)title withDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal;
+ (void)say:(NSString *)title message:(NSString*)message withDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal;

+ (void)ask: (NSString *) question withDeal:(void(^)(bool answer))deal;
+ (void) askWithDeal:(void (^)(bool answer))deal andQuestion:(id)formatstring,...;

+ (void)confirm: (NSString *) question withDeal:(void(^)(bool answer))deal;
+ (void)confirm:(NSString*) question otherButtons:(NSArray*)buttons withDeal:(void(^)(bool answer))deal;
+ (void) confirmWithDeal:(void (^)(bool answer))deal andQuestion:(id)formatstring,...;

@end

@interface DetailBlockAlertView : UIBlockAlertView
+ (void) confirmWithDeal:(void (^)(bool answer))deal detail:(NSString *)details andQuestion:(id)formatstring,...;
@end
