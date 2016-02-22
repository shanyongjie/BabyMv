//
//  ActionSheetX.h
//  MPNotificationViewTest
//
//

#import <UIKit/UIKit.h>
typedef void (^ActionSheetXCallBack)(int item, NSString* title);//-1 is cancel, other is choiced item


@interface UIActionSheet (Sync)

+ (void)actionSheetWithTitle:(NSString *)title
           cancelButtonTitle:(NSString *)cancelButtonTitle
      destructiveButtonTitle:(NSString *)destructiveButtonTitle
           otherButtonTitles:(NSArray *)otherButtonTitles
                        view:(UIView *)view
                    callback:(ActionSheetXCallBack)callback;

+ (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
+ (void)dismissActionSheetAnimated:(BOOL)animated;

@end




/*
EXAMPLE


 
 __block UIView* selfView = self.view;
 
 void (^callback3)(int item) = ^(int item){
 NSLog(@"callback3: %d", item);
 };
 void (^callback2)(int item) = ^(int item){
 NSLog(@"callback2: %d", item);
 
 dispatch_async(dispatch_get_main_queue(), ^{
 UIView* ui = [[UIView alloc]init];
 
 NSArray* arra1y = [NSArray arrayWithObjects:@"Ok", @"one", nil];
 
 [UIActionSheet actionSheetWithTitle:@"title a2lsakdjfa;lsdkjf;aldjskfa;lsdjkf" cancelButtonTitle:nil destructiveButtonTitle:@"des" otherButtonTitles:arra1y view:selfView callback:callback3];
 });
 };
 void (^callback)(int item) = ^(int item)
 {
 NSLog(@"choice: %d", item);
 if(item == 1){
 
 dispatch_async(dispatch_get_main_queue(), ^{
 UIView* ui = [[UIView alloc]init];
 
 NSArray* arra1y = [NSArray arrayWithObjects:@"Ok", @"one", nil];
 
 [ActionSheetX actionSheetWithTitle:@" Go nect" cancelButtonTitle:nil destructiveButtonTitle:@"des" otherButtonTitles:arra1y view:selfView callback:callback2];
 });
 }
 };
 NSArray* arra1y = [NSArray arrayWithObjects:@"____Click This_____", @"two", nil];
 [UIActionSheet actionSheetWithTitle:@"title" cancelButtonTitle:@"cancel" destructiveButtonTitle:@"des" otherButtonTitles:arra1y view:self.view callback:callback];
 
 


*/