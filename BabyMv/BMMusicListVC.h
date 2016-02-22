//
//  BMMusicListVC.h
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDefinition.h"


@class BMCollectionDataModel;
@class BMCartoonCollectionDataModel;

@interface BMMusicListVC : UIViewController
@property(nonatomic, assign)MyListVCType vcType;
@property(nonatomic, strong)BMCollectionDataModel* currentCollectionData;
@property(nonatomic, strong)BMCartoonCollectionDataModel* currentCartoonCollectionData;
@end
