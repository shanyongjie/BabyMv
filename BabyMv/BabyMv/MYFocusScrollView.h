
#import <UIKit/UIKit.h>

@protocol MYFocusViewDelegate <NSObject>
- (void)focusViewClicked:(UIButton *) btn;
@end

@interface MYFocusView : UIView
- (instancetype)initWithFrame:(CGRect)frame itemCounts:(NSUInteger)itemCounts;
- (void)loadScrollView;
- (void)setClickDelegate:(id<MYFocusViewDelegate>)delegate;
@end

@interface MYFocusScrollView : UIScrollView
@property (assign, nonatomic)NSUInteger pages;
@property (assign, nonatomic)id<MYFocusViewDelegate> clickDelegate;
- (instancetype)initWithFrame:(CGRect)frame itemCounts:(NSUInteger)itemCounts;
- (void)loadItems;
@end
