//
//  BMRequestManager.h
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroDefinition.h"

@interface BMRequestManager : NSObject
+(instancetype)sharedInstance;
+(void)loadCategoryData:(MyRequestType)requestType;
-(void)loadListDataWithCollectionId:(NSNumber *)collectionId requestType:(MyRequestType)requestType;
-(void)loadCollectionDataWithCategoryId:(NSNumber *)musicCateId requestType:(MyRequestType)requestType;
@end
