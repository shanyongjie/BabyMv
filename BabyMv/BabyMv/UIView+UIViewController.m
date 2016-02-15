
#import "UIView+UIViewController.h"

@implementation UIView (UIViewController)

-(UIViewController*)viewController
{
    for (UIResponder *nextResponder = [self nextResponder]; nextResponder; nextResponder = nextResponder.nextResponder) {
         if ([nextResponder isKindOfClass:[UIViewController class]]) {
             return (UIViewController *)nextResponder;
         }
    }
    return nil;
}

@end
