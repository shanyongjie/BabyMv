//
//  PopupMenuView.h
//  RingtoneDuoduo
//
//  Created by mistyzyq on 14-1-8.
//  Copyright (c) 2013年 www.ShoujiDuoduo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupMenuView;

@protocol PopupMenuDelegate <NSObject>

@optional
- (void)popupMenuWillShow:(PopupMenuView*)menu;
- (void)popupMenuDidShow:(PopupMenuView*)menu;

- (void)popupMenuWillHide:(PopupMenuView*)menu;
- (void)popupMenuDidHide:(PopupMenuView*)menu;

//- (void)popupMenu:(PopupMenuView*)menu didSelectItemIndex:(NSInteger)index;

@end

@interface PopupMenuView : UIView

@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, assign) id<PopupMenuDelegate> delegate;
@property (nonatomic, assign) NSInteger itemIndex;
@property (nonatomic, readonly) BOOL isShown;

- (void)addItemWithText: (NSString *)text
				  image:(UIImage *)image
			andSelector: (SEL)selector  // handleMenuCommand:(id)userData
               userData:(id)userData;

// drop flags is reserved, and ignored currently.
- (void) showInView:(UIView*)view withAnchorPoint:(CGPoint)anchorPoint dropFlags:(int)dropFlags animated:(BOOL)animated;
- (void) hide:(BOOL)animated;

@end
