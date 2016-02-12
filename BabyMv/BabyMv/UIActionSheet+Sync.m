//
//  ActionSheetX.m
//  MPNotificationViewTest
//
//

#import "UIActionSheet+Sync.h"

@interface ActionSheetX : NSObject<UIActionSheetDelegate>

+ (void)actionSheetWithTitle:(NSString *)title
           cancelButtonTitle:(NSString *)cancelButtonTitle
      destructiveButtonTitle:(NSString *)destructiveButtonTitle
           otherButtonTitles:(NSArray *)otherButtonTitles
                        view:(UIView *)view
                    callback:(ActionSheetXCallBack)callback;
@end

@interface ActionSheetX ()

@property (nonatomic, copy) ActionSheetXCallBack callback;
@property (nonatomic, strong) NSArray* menuData;
@property (nonatomic, retain) UIActionSheet* actionSheet;

@end


@implementation ActionSheetX

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int choiceItem = buttonIndex;
    if (actionSheet.cancelButtonIndex > -1 && buttonIndex ==  actionSheet.numberOfButtons - 1)
    {
		//cancel button clicked
        //MOTrace(NSLog(@"cancel"));
        choiceItem = -1;
    }
    else
    {
		//other button
    }
	
    if (self.callback)
    {
   
        ActionSheetXCallBack cb = [self.callback copy];
        NSMutableArray* array = [_menuData mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(choiceItem>=0)
            {
                cb(choiceItem, array[choiceItem]);
            }
            else
            {
                cb(choiceItem, nil);
            }
            if(self == as) {
                as = nil;
            }
        });
    }
	
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if(self == as) {
//            as = nil;
//        }
//    });
}

- (void)__actionSheetWithTitle:(NSString *)title
             cancelButtonTitle:(NSString *)cancelButtonTitle
        destructiveButtonTitle:(NSString *)destructiveButtonTitle
             otherButtonTitles:(NSArray *)otherButtonTitles
                          view:(UIView *)view
                      callback:(ActionSheetXCallBack)cb
{
    self.callback = cb;
	
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];

    NSMutableArray *btnTitles = [NSMutableArray arrayWithArray:otherButtonTitles];
    if(destructiveButtonTitle != nil) {
        [btnTitles addObject:destructiveButtonTitle];
        _actionSheet.destructiveButtonIndex=btnTitles.count-1;
    }
    self.menuData = btnTitles;
    for (int i = 0; i < btnTitles.count; i++)
    {
        [_actionSheet addButtonWithTitle:[btnTitles objectAtIndex:i]];
    }
    if (cancelButtonTitle) _actionSheet.cancelButtonIndex = [_actionSheet addButtonWithTitle:cancelButtonTitle];
    [_actionSheet showInView:view];
}

- (void)__dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (!_actionSheet) return;
    [_actionSheet dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

static ActionSheetX *as;
+ (void)actionSheetWithTitle:(NSString *)title
           cancelButtonTitle:(NSString *)cancelButtonTitle
      destructiveButtonTitle:(NSString *)destructiveButtonTitle
           otherButtonTitles:(NSArray *)otherButtonTitles
                        view:(UIView *)view
                    callback:(ActionSheetXCallBack)callback
{
    as = [[ActionSheetX alloc] init];
    [as __actionSheetWithTitle:title
			 cancelButtonTitle:cancelButtonTitle
		destructiveButtonTitle:destructiveButtonTitle
			 otherButtonTitles:otherButtonTitles
						  view:view
					  callback:callback]; 
}

+ (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (!as) return;
    [as __dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

+ (NSInteger)cancelButtonIndex {
    return as.actionSheet.cancelButtonIndex;
}

@end

@implementation UIActionSheet (Sync)

+ (void)actionSheetWithTitle:(NSString *)title
           cancelButtonTitle:(NSString *)cancelButtonTitle
      destructiveButtonTitle:(NSString *)destructiveButtonTitle
           otherButtonTitles:(NSArray *)otherButtonTitles
                        view:(UIView *)view
                    callback:(ActionSheetXCallBack)callback
{
    [ActionSheetX actionSheetWithTitle:title
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle
                     otherButtonTitles:otherButtonTitles
                                  view:view callback:callback];
}

+ (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [ActionSheetX dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

+ (void)dismissActionSheetAnimated:(BOOL)animated
{
    [ActionSheetX dismissWithClickedButtonIndex:[ActionSheetX cancelButtonIndex] animated:animated];
}

@end
