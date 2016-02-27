/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

/*
 Thanks to Kevin Ballard for suggesting the UITextField as subview approach
 All credit to Kenny TM. Mistakes are mine. 
 To Do: Ensure that only one runs at a time -- is that possible?
 */

#import "ModalAlert.h"
#import <stdarg.h>

#define TEXT_FIELD_TAG	9999

typedef enum UIAlertViewType {
    UIAlertViewTypeNone,
    UIAlertViewTypeAsk,
    UIAlertViewTypeConfirm,
    UIAlertViewTypeSay,
} UIAlertViewType;

@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate, UITextFieldDelegate> 
{
	CFRunLoopRef currentLoop;
	NSString *text;
	NSUInteger index;
}
@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,strong) NSString *text;
@end

@implementation ModalAlertDelegate
@synthesize index;
@synthesize text;

-(id) initWithRunLoop: (CFRunLoopRef)runLoop 
{
	if (self = [super init]) currentLoop = runLoop;
	return self;
}

// User pressed button. Retrieve results
-(void)alertView:(UIAlertView*)aView clickedButtonAtIndex:(NSInteger)anIndex 
{
	UITextField *tf = (UITextField *)[aView viewWithTag:TEXT_FIELD_TAG];
	if (tf) self.text = tf.text;
	self.index = anIndex;
	CFRunLoopStop(currentLoop);
}

- (BOOL) isLandscape
{
	return ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight);
}

// Move alert into place to allow keyboard to appear
- (void) moveAlert: (UIAlertView *) alertView
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	if (![self isLandscape])
		alertView.center = CGPointMake(160.0f, 180.0f);
	else 
		alertView.center = CGPointMake(240.0f, 90.0f);
	[UIView commitAnimations];
	
	[[alertView viewWithTag:TEXT_FIELD_TAG] becomeFirstResponder];
}


@end


@implementation ModalAlert

+ (NSUInteger) ask: (NSString *) question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons
{
//    [UIView setAnimationsEnabled:NO];
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	// Create Alert
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:madelegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
	for (NSString *buttonTitle in buttons) [alertView addButtonWithTitle:buttonTitle];
	[alertView show];
	
	// Wait for response
	CFRunLoopRun();
	
	// Retrieve answer
	NSUInteger answer = madelegate.index;
//    [UIView setAnimationsEnabled:YES];
	return answer;
}

+(void) say: (NSString *) formatstring
{
    UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@""
                                                 message:formatstring
                                                delegate:nil
                                       cancelButtonTitle:nil
                                       otherButtonTitles:STRING(@"知道了"),nil];
    [alert show];
}

+(void) say:(NSString *) formatstring withButtonTitles:(NSString *) buttonTitles
{
    UIAlertView*alert=[[UIAlertView alloc] initWithTitle:@""
                                                 message:formatstring
                                                delegate:nil
                                       cancelButtonTitle:nil
                                       otherButtonTitles:buttonTitles,nil];
    [alert show];
}

+ (void) sayold: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	[ModalAlert ask:statement withCancel:STRING(@"好的") withButtons:nil];
}

+ (BOOL) ask: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	BOOL answer = ([ModalAlert ask:statement withCancel:nil withButtons:[NSArray arrayWithObjects:STRING(@"是"),STRING( @"否"), nil]] == 0);
	return answer;
}

+ (BOOL) confirm: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	BOOL answer = [ModalAlert ask:statement withCancel:STRING(@"取消") withButtons:[NSArray arrayWithObject:STRING(@"确定")]];
	return	answer;
}

+(NSString *) textQueryWith: (NSString *)question prompt: (NSString *)prompt button1: (NSString *)button1 button2:(NSString *) button2 input_text:(NSString *)inputText
{
	// Create alert
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n" delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
	
	// Build text field
	UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
	tf.borderStyle = UITextBorderStyleRoundedRect;
	tf.tag = TEXT_FIELD_TAG;
	tf.placeholder = prompt;
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.keyboardType = UIKeyboardTypeAlphabet;
	//tf.keyboardAppearance = UIKeyboardAppearanceAlert;
	tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
	tf.autocorrectionType = UITextAutocorrectionTypeNo;
	tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	if (inputText)
    {
        tf.text = inputText;
    }
	// Show alert and wait for it to finish displaying
	[alertView show];
	while (CGRectEqualToRect(alertView.bounds, CGRectZero));
	
	// Find the center for the text field and add it
	CGRect bounds = alertView.bounds;
	tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f);
	[alertView addSubview:tf];
	
	// Set the field to first responder and move it into place
	[madelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 0.7f];
	
	// Start the run loop
	CFRunLoopRun();
	
	// Retrieve the user choices
	NSUInteger index = madelegate.index;
	NSString *answer = [madelegate.text copy];
	if (index == 0) answer = nil; // assumes cancel in position 0
	
	return answer;
}

+ (NSString *) ask: (NSString *) question withTextPrompt: (NSString *) prompt
{
	return [ModalAlert textQueryWith:question prompt:prompt button1:STRING(@"取消") button2:STRING(@"确定") input_text:nil];
}
+ (NSString *) ask: (NSString *) question withText: (NSString *) text
{
	return [ModalAlert textQueryWith:question prompt:nil button1:STRING(@"取消") button2:STRING(@"确定") input_text:text];
}
@end


@implementation UIBlockAlertView

@synthesize alertViewStyle = _alertViewStyle;


- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtons: (NSArray *) buttons andDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal
{
    return [self initWithTitle:title message:nil cancelButtonTitle:cancelButtonTitle otherButtons:buttons andDeal:deal];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtons: (NSArray *) buttons andDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal
{
    self = [self initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (self) {
        for (NSString *buttonTitle in buttons) [self addButtonWithTitle:buttonTitle];
        self.delegate = self;
        _block = [deal copy];
        _type = UIAlertViewTypeNone;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title type:(UIAlertViewType)alertType otherButtons: (NSArray *) buttons andDeal:(void(^)(bool answer))deal
{
    self = [self initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        _type = alertType;
        for (NSString *buttonTitle in buttons) [self addButtonWithTitle:buttonTitle];
        self.delegate = self;
        _boolBlock = [deal copy];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title detail:(NSString *)details type:(UIAlertViewType)alertType otherButtons: (NSArray *) buttons andDeal:(void(^)(bool answer))deal
{
    self = [self initWithTitle:title message:details delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        _type = alertType;
        for (NSString *buttonTitle in buttons) [self addButtonWithTitle:buttonTitle];
        self.delegate = self;
        _boolBlock = [deal copy];
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (_type) {
        case UIAlertViewTypeAsk:
            if (_boolBlock) {
                _boolBlock(buttonIndex==0);
            }
            break;
        case UIAlertViewTypeConfirm:
            if (_boolBlock) {
                _boolBlock(buttonIndex==1);
            }
            break;
        case UIAlertViewTypeSay:
            if (_boolBlock) {
                _boolBlock(YES);
            }
            break;
        default:
            if (_block) {
                _block(self,buttonIndex);
            }
            break;
    }
}

-(void) setAlertViewStyle:(UIAlertViewStyle)alertViewStyle
{
    if ([[super class] instancesRespondToSelector:@selector(alertViewStyle)]) {
        //ios5.0+
        [super setAlertViewStyle:alertViewStyle];
    }
    else {
        //ios5.0-
        switch (alertViewStyle) {
            case UIAlertViewStyleDefault:
                break;
            case UIAlertViewStylePlainTextInput:
            case UIAlertViewStyleSecureTextInput:
            {
                self.message = @"\n";
                _inputfield = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
                [_inputfield setKeyboardType:UIKeyboardTypeDefault];
                [_inputfield setBorderStyle:UITextBorderStyleLine];
                [_inputfield becomeFirstResponder];
                [_inputfield setBackgroundColor:[UIColor whiteColor]];
                if (UIAlertViewStyleSecureTextInput == alertViewStyle) {
                    _inputfield.secureTextEntry = YES;
                }
                [self addSubview:_inputfield];
                CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
                [self setTransform: moveUp];
            }
                break;
                break;
            case UIAlertViewStyleLoginAndPasswordInput:
                break;
            default:
                break;
        }
    }
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    if ([[super class] instancesRespondToSelector:@selector(textFieldAtIndex:)]) {
        //ios5.0+
        return [super textFieldAtIndex:textFieldIndex];
    }
    else {
        //ios5.0-
            return _inputfield;
    }
    return nil;
}

+ (void)say:(NSString *) title withDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal
{
    return [UIBlockAlertView say:title message:nil withDeal:deal];
}

+ (void)say:(NSString *)title message:(NSString*)message withDeal:(void(^)(UIBlockAlertView* alert, NSInteger clickIndex))deal
{
    // Create Alert
    UIBlockAlertView *alertView = [[UIBlockAlertView alloc] initWithTitle:title
                                                                  message:message
                                                        cancelButtonTitle:STRING(@"知道了")
                                                             otherButtons:nil
                                                                  andDeal:deal];
    //    alertView.delegate = alertView;
    [alertView show];
}

//+ (void)say:(NSString *)formatstring withDeal:(void(^)(bool answer))deal
//{
//    UIBlockAlertView *alertView = [[UIBlockAlertView alloc] initWithTitle:formatstring
//                                                                     type:UIAlertViewTypeSay
//                                                             otherButtons:[NSArray arrayWithObjects:@"知道了",nil]
//                                                                  andDeal:deal];
//    
//    [alertView show];
//    [alertView release];
//}


+ (void)ask: (NSString *) question withDeal:(void(^)(bool answer))deal
{
	
	// Create Alert
	UIBlockAlertView *alertView = [[UIBlockAlertView alloc] initWithTitle:question
                                                                     type:UIAlertViewTypeAsk
                                                             otherButtons:[NSArray arrayWithObjects:STRING(@"是"),STRING(@"否"),nil]
                                                                  andDeal:deal];
    //    alertView.delegate = alertView;
	[alertView show];
    
}

+ (void) askWithDeal:(void (^)(bool answer))deal andQuestion:(id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	[[self class] ask:statement withDeal:deal];
}

+ (void)confirm: (NSString *) question withDeal:(void(^)(bool answer))deal
{
	
	// Create Alert
	UIBlockAlertView *alertView = [[UIBlockAlertView alloc] initWithTitle:question
                                                                     type:UIAlertViewTypeConfirm
                                                             otherButtons:[NSArray arrayWithObjects:@"取消",@"确定",nil]
                                                                  andDeal:deal];

    //    alertView.delegate = alertView;
	[alertView show];
    
}

+ (void)confirm:(NSString*) question otherButtons:(NSArray*)buttons withDeal:(void(^)(bool answer))deal
{
    // Create Alert
    UIBlockAlertView *alertView = [[UIBlockAlertView alloc] initWithTitle:question
                                                                     type:UIAlertViewTypeConfirm
                                                             otherButtons:buttons
                                                                  andDeal:deal];
    
    //    alertView.delegate = alertView;
    [alertView show];
}

+ (void)confirm: (NSString *) question detail:(NSString *)details withDeal:(void(^)(bool answer))deal
{
    // Create Alert
    UIBlockAlertView *alertView = [[UIBlockAlertView alloc] initWithTitle:question
                                                                   detail:details
                                                                     type:UIAlertViewTypeConfirm
                                                             otherButtons:[NSArray arrayWithObjects:@"取消",@"确定",nil]
                                                                  andDeal:deal];
    
    //    alertView.delegate = alertView;
    [alertView show];
}

+ (void) confirmWithDeal:(void (^)(bool answer))deal andQuestion:(id)formatstring,...
{
    va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
    [[self class] confirm:statement withDeal:deal];
}
@end

@implementation DetailBlockAlertView

+ (void) confirmWithDeal:(void (^)(bool answer))deal detail:(NSString *)details andQuestion:(id)formatstring,...
{
    va_list arglist;
    va_start(arglist, formatstring);
    id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
    va_end(arglist);
    [[self class] confirm:statement detail:details withDeal:deal];
}

@end
