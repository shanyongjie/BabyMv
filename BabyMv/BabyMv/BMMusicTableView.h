//
//  BMMusicTableView.h
//  BabyMv
//
//  Created by ma on 2/7/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDefinition.h"

@interface BMMusicTableView : UITableView
@property(nonatomic, assign)MyTableViewType myType;
-(void)setSongItems:(NSArray *)items;
@end

