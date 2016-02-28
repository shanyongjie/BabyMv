//
//  PopupMenuView.m
//  RingtoneDuoduo
//
//  Created by mistyzyq on 14-1-8.
//  Copyright (c) 2013年 www.ShoujiDuoduo.com. All rights reserved.
//

#import "MenuItem.h"
#import "PopupMenuView.h"
#import "common.h"

#define MENU_ITEM_HEIGHT (40)
#define MENU_ITEM_WIDTH 165
#define MENU_MARGIN_H 0
#define MENU_MARGIN_V 0

@interface PopupMenuView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL _isShown;
}

@end

@implementation PopupMenuView

@synthesize isShown = _isShown;

- (void)addItemWithText: (NSString *)text
				  image:(UIImage *)image
			andSelector: (SEL)selector
               userData:(id)userData
{
	MenuItem *item = [MenuItem menuItemWithImage:image title:text action:selector userData:userData];
	[self.items addObject:item]; 
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
		UIImage *image = [[UIImage imageNamed:@"menu_background.png"] stretchableImageWithLeftCapWidth:IMAGE_CAP_AVERAGE topCapHeight:IMAGE_CAP_AVERAGE];
		_bgImageView = [[UIImageView alloc] initWithImage:image];
		[self addSubview:_bgImageView];
		
		self.items = [NSMutableArray arrayWithCapacity:4];

		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		[_tableView setSeparatorColor:RGBCOLORVALUE(0xE8E8E8)];
		_tableView.backgroundColor = [UIColor whiteColor];
		_tableView.layer.borderWidth = 1.f;
		_tableView.layer.borderColor = RGBCOLORVALUE(0xCACACA).CGColor;
		_tableView.layer.cornerRadius = 3.f;
		_tableView.scrollEnabled = NO;
		_tableView.dataSource = self;
		_tableView.delegate = self;
		[self addSubview:_tableView];
		
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self addGestureRecognizer:_tapRecognizer];
		_tapRecognizer.delegate = self;
    }
    return self;
}

- (CGPoint) getMenuBasePointWithX:(CGFloat)x y:(CGFloat)y
{
	CGPoint expectedBasePoint = CGPointMake(x, y);
	CGFloat width = MENU_ITEM_WIDTH + MENU_MARGIN_H * 2;
	CGFloat height = self.items.count * MENU_ITEM_HEIGHT + MENU_MARGIN_V * 2;
	CGPoint point;
	CGRect containerRect = self.bounds;
	if (CGPointEqualToPoint(expectedBasePoint, CGPointZero)) {
		point = CGPointZero;
	} else {
		point.x = expectedBasePoint.x - width;
		if (expectedBasePoint.y + height > CGRectGetMaxY(containerRect)) {
			point.y = CGRectGetMaxY(containerRect) - height;
		} else {
			point.y = expectedBasePoint.y;
		}
	}
	return point;
}

- (void) showInView:(UIView*)view withAnchorPoint:(CGPoint)anchorPoint dropFlags:(int)dropFlags animated:(BOOL)animated
{
    if (self.isShown)
        return;

    _isShown = YES;
    [self retain];

	CGFloat width = MENU_ITEM_WIDTH + MENU_MARGIN_H * 2;
	CGFloat height = self.items.count * MENU_ITEM_HEIGHT + MENU_MARGIN_V * 2;
    anchorPoint.y -= height;
    UIView* parentView = [[UIApplication sharedApplication] keyWindow];
    self.frame = parentView.bounds;
    self.alpha = 0.f;
    [parentView addSubview:self];

    if (view) anchorPoint = [view convertPoint:anchorPoint toView:self];
	CGRect rcMenu = CGRectMake(0, 0, width, height);
    OffsetRectToXY(&rcMenu, anchorPoint.x - width, anchorPoint.y);
	self.bgImageView.frame = rcMenu;
	DeflateRectXY(&rcMenu, MENU_MARGIN_H, MENU_MARGIN_V);
	self.tableView.frame = TopRect(rcMenu, 0, 0);

    void(^showBlock)() = ^{
        self.alpha = 1.f;
        self.tableView.frame = rcMenu;
    };
    if (animated) {
        [UIView animateWithDuration:0.1 animations:showBlock];
    } else {
        showBlock();
    }
}

- (void) hide:(BOOL)animated
{
    if (!self.isShown)
        return;

    _isShown = NO;

    void(^hideBlock)() = ^{
        self.alpha = 0;
    };
    void(^completeBlock)(BOOL finished) = ^(BOOL finished) {
        self.delegate = nil;
        [self removeFromSuperview];
        [self autorelease];
    };
    if (animated) {
        [UIView animateWithDuration:0.1 animations:hideBlock completion:completeBlock];
	} else {
        hideBlock();
        completeBlock(YES);
    }
}

- (void)onSelectItemAtIndex:(int)index
{
//    [delegate popupMenu:self didSelectItemIndex:itemIndex];

    MenuItem* item = [self.items objectAtIndex:index];
    if (self.delegate && item.selector) {
        [self.delegate performSelector:item.selector withObject:item.userData];
    }

    [self hide:YES];
}

- (void)dealloc
{
	[_bgImageView release];
	[_tableView release];
	[_items release];
	[_tapRecognizer release];
	[super dealloc];
}

- (void)handleTapGesture:(UIGestureRecognizer*)gestureRecognizer
{
    [self hide:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"popupMenuItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
        cell.selectedBackgroundView.backgroundColor = RGBCOLORVALUE(0xF8F8F8);
    }
	MenuItem *item =  [self.items objectAtIndex:indexPath.row];
	cell.imageView.image = item.image;
	cell.textLabel.text = item.title;
    if (item.highColor) {
        [cell.textLabel setTextColor:item.highColor];
    }else {
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return MENU_ITEM_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self onSelectItemAtIndex:(indexPath.row)];
}

#pragma mark - gesture recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    CGRect rect = self.tableView.frame;
    if (CGRectContainsPoint(rect, point)) 
        return NO;
    return YES;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect menuRect = self.tableView.frame;
    if (CGRectContainsPoint(menuRect, point))
        return;
	[self hide:YES];
}

@end
