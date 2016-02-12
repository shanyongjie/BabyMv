

#import "MYFocusScrollView.h"
#import "MacroDefinition.h"

@interface MYFocusView ()<UIScrollViewDelegate>
@property (strong, nonatomic)UIPageControl *pageControl;
@property(strong, nonatomic) MYFocusScrollView *focusScrollView;
@end

@implementation MYFocusView

- (instancetype)initWithFrame:(CGRect)frame itemCounts:(NSUInteger)itemCounts{
    self = [super initWithFrame:frame];
    if (self) {
/////           ///////////////
        [_focusScrollView removeFromSuperview];
        ///////////
        _focusScrollView = [[MYFocusScrollView alloc] initWithFrame:frame itemCounts:itemCounts];
        _focusScrollView.delegate = self;
        [self addSubview:_focusScrollView];

        _pageControl = [[UIPageControl alloc] init];
        //        _pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _pageControl.backgroundColor=[UIColor clearColor];
        _pageControl.pageIndicatorTintColor=[UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor=[UIColor blackColor];
        //        _pageControl.pageIndicatorTintColor= RGB(0x808080, 1);
        //        _pageControl.currentPageIndicatorTintColor= RGB(0x555555, 1);
        
        _pageControl.enabled = NO;
        
        //        [_pageControl addTarget:self action:@selector(changeCurrentPage:)
        //              forControlEvents:UIControlEventValueChanged];
        //        [self addSubview:_pageControl];
        [self addSubview:_pageControl];
    }
    return self;
}

- (void)loadScrollView {
    [_focusScrollView loadItems];

    self.frame = _focusScrollView.frame;
    _pageControl.frame = CGRectMake(0, _focusScrollView.frame.size.height-18, _focusScrollView.frame.size.width, 18);
    if (_focusScrollView.pages < 1) {
        _pageControl.hidden = YES;
        _pageControl.numberOfPages = 1;
    } else {
        _pageControl.numberOfPages = _focusScrollView.pages + 1;
        _pageControl.hidden = NO;
        [self bringSubviewToFront:_pageControl];
        _pageControl.currentPage = 0;
    }

}

- (void)setClickDelegate:(id<MYFocusViewDelegate>)delegate {
    _focusScrollView.clickDelegate = delegate;
}

#pragma mark scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger pageIndex = scrollView.contentOffset.x/self.frame.size.width;
    _pageControl.currentPage = pageIndex;
}

@end


@interface MYFocusScrollView ()
@property (assign, nonatomic)NSUInteger itemCounts;
@property (strong, nonatomic)NSArray *circleViewLayerArr;
@end



@implementation MYFocusScrollView

- (instancetype)initWithFrame:(CGRect)frame itemCounts:(NSUInteger)itemCounts{
    self = [super initWithFrame:frame];
    if (self) {
        _itemCounts = itemCounts;
        _circleViewLayerArr = [NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:0xff8632],
                                       [NSNumber numberWithInt:0x38abf4],
                                       [NSNumber numberWithInt:0xfd532d],
                                       [NSNumber numberWithInt:0x1ec08f],
                                       [NSNumber numberWithInt:0x9f68e7],
                                       [NSNumber numberWithInt:0x3acd3c],
                                       [NSNumber numberWithInt:0xfe545c],
                                       [NSNumber numberWithInt:0xe39a63],
                                       nil];
    }
    return self;
}

- (void)loadItems {
//    NSArray *frameArr3 = [self itemFrame:CGRectMake(0, 0, MAIN_WIDTH, 142) Edges:CGRectMake(19, 8, 19, 8) ColumnsAndLines:CGPointMake(4, 2) itemSize:CGSizeMake(43, 43+5+11) itemCounts:7];
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    NSDictionary *dic = [self scrollViewFrameContent:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) Edges:CGRectMake(19, 8, 19, 18) ColumnsAndLines:CGPointMake(4, 2) itemSize:CGSizeMake(43, 43+5+11) itemCounts:_itemCounts];
    CGRect scrollViewFrame = [(NSValue *)[dic objectForKey:@"scrollViewFrame"] CGRectValue];
    CGSize scrollViewContent = [[dic objectForKey:@"scrollViewContent"] CGSizeValue];
    
    NSArray *frameArr3 = [self itemFrame:self.frame Edges:CGRectMake(19, 8, 19, 18) ColumnsAndLines:CGPointMake(4, 2) itemSize:CGSizeMake(43, 43+5+11) itemCounts:_itemCounts];
    
    for (NSUInteger itemIndex = 0; itemIndex < _itemCounts; ++itemIndex) {
        NSValue *val = frameArr3[itemIndex];
        CGRect frame = [val CGRectValue];
        UILabel *lab = [[UILabel alloc] initWithFrame:frame];
//        lab.layer.borderWidth = 1;
//        lab.layer.borderColor = [UIColor redColor].CGColor;
        [self addSubview:lab];
        
        UIButton *circleView = [UIButton buttonWithType:UIButtonTypeCustom];
        [circleView setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width)];
        circleView.layer.cornerRadius = frame.size.width/2;
        [circleView setImage:[UIImage imageNamed:@"group_chat"] forState:UIControlStateNormal];
        circleView.layer.masksToBounds = YES;
        int colorIndex = itemIndex%8;
        UIColor *layerColor;
        switch (colorIndex) {
            case 0:
                layerColor = RGB(0xff8632, 1.0);
                break;
            case 1:
                layerColor = RGB(0x38abf4, 1.0);
                break;
            case 2:
                layerColor = RGB(0xfd532d, 1.0);
                break;
            case 3:
                layerColor = RGB(0x1ec08f, 1.0);
                break;
            case 4:
                layerColor = RGB(0x9f68e7, 1.0);
                break;
            case 5:
                layerColor = RGB(0x3acd3c, 1.0);
                break;
            case 6:
                layerColor = RGB(0xfe545c, 1.0);
                break;
            case 7:
                layerColor = RGB(0xe39a63, 1.0);
                break;
                
            default:
                break;
        }
        circleView.layer.borderWidth = 1.5;
        circleView.layer.borderColor = layerColor.CGColor;
        
        [circleView addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        circleView.tag = 1000 + itemIndex;
        [self addSubview:circleView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+43+5, frame.size.width, 11)];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont systemFontOfSize:10];
        titleLab.text = @"";
        titleLab.tag = 2000 + itemIndex;
        CGSize textSize = [titleLab.text sizeWithFont:titleLab.font constrainedToSize:CGSizeMake(frame.size.width+30, 11) lineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:titleLab];
    }
    self.frame = scrollViewFrame;
    self.contentSize = scrollViewContent;
}

- (NSArray *)itemFrame:(CGRect)wholeFrame Edges:(CGRect)edges ColumnsAndLines:(CGPoint)columnsLines itemSize:(CGSize)itemSize itemCounts:(NSUInteger) itemCounts {
    NSMutableArray *arrTemp = [NSMutableArray new];
    NSMutableArray *arrResult = [NSMutableArray new];
    
    CGFloat left = edges.origin.x;
    CGFloat top = edges.origin.y;
    CGFloat right = edges.size.width;
    CGFloat bottom = edges.size.height;
    
    NSUInteger xnums = columnsLines.x;
    NSUInteger ynums = columnsLines.y;
    NSUInteger perPage = xnums*ynums;
    
    if (columnsLines.x * columnsLines.y > 1 &&
        wholeFrame.size.width >= columnsLines.x*itemSize.width+left+right &&
        wholeFrame.size.height >= columnsLines.y*itemSize.height+top+bottom) {
        
        //根据item大小、屏幕尺寸，自动调整item之间的间隔；
        CGFloat xgap = (xnums>1) ? (wholeFrame.size.width - left - right - xnums*itemSize.width) / (xnums-1) : 0.0f;
        CGFloat ygap = (ynums>1) ? (wholeFrame.size.height - top - bottom - ynums*itemSize.height) / (ynums-1) : 0.0f;
        
        for (NSUInteger index = 0; index < perPage; ++index) {
            CGRect frame;
            frame.size.width = itemSize.width;
            frame.size.height = itemSize.height;
            frame.origin.x = left + (index%xnums)*(itemSize.width+xgap) + wholeFrame.origin.x;
            frame.origin.y = top + (index/xnums)*(itemSize.height+ygap) + wholeFrame.origin.y;
            NSValue *frameValue = [NSValue valueWithCGRect:frame];
            [arrTemp addObject:frameValue];
        }
        [arrResult addObjectsFromArray:arrTemp];
        
        for (NSUInteger pag = 1; pag <= _pages; ++pag) {
            NSUInteger startPTx = pag * wholeFrame.size.width;
            
            for (NSValue *value in arrTemp) {
                CGRect frame = [value CGRectValue];
                frame.origin.x += startPTx;
                NSValue *frameValue = [NSValue valueWithCGRect:frame];
                [arrResult addObject:frameValue];
            }
        }
    }
    return arrResult;
}


- (NSDictionary *)scrollViewFrameContent:(CGRect)wholeFrame Edges:(CGRect)edges ColumnsAndLines:(CGPoint)columnsLines itemSize:(CGSize)itemSize itemCounts:(NSUInteger) itemCounts {
    CGFloat left = edges.origin.x;
    CGFloat top = edges.origin.y;
    CGFloat right = edges.size.width;
    CGFloat bottom = edges.size.height;
    
    NSUInteger xnums = columnsLines.x;
    NSUInteger ynums = columnsLines.y;
    NSUInteger perPage = xnums*ynums;
    _pages = itemCounts/perPage;
    
    CGFloat ygap = (ynums>1) ? (wholeFrame.size.height - top - bottom - ynums*itemSize.height) / (ynums-1) : 0.0f;
    
    CGRect scrollViewFrame;
    CGSize scrollViewContent;
    
    if (columnsLines.x * columnsLines.y > 1 &&
        wholeFrame.size.width >= columnsLines.x*itemSize.width+left+right &&
        wholeFrame.size.height >= columnsLines.y*itemSize.height+top+bottom) {
        if (_pages < 1) {
            scrollViewFrame = wholeFrame;
            //如果item只有一页，那就需要计算item是否铺满了该页所有的行。如果没有铺满，则需要shrink
            NSUInteger realYnums = itemCounts/xnums + 1;
            scrollViewFrame.size.height -= (ynums-realYnums)*(ygap+itemSize.height);
            scrollViewContent.height = scrollViewFrame.size.height;
            scrollViewContent.width = wholeFrame.size.width;
        } else {
            scrollViewFrame = wholeFrame;
            scrollViewContent.height = wholeFrame.size.height;
            scrollViewContent.width = wholeFrame.size.width * (_pages+1);
        }
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:scrollViewFrame], @"scrollViewFrame", [NSValue valueWithCGSize:scrollViewContent], @"scrollViewContent", nil];
    }
    return nil;
}

- (void)btnClicked:(UIButton *) btn {
    if ([_clickDelegate respondsToSelector:@selector(focusViewClicked:)]) {
        [_clickDelegate focusViewClicked:btn];
    }
}

@end
