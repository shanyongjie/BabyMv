//
//  BMRequestManager.h
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMRequestManager : NSObject
+(instancetype)sharedInstance;
+(void)loadCategoryData;
-(void)loadListDataWithCollectionId:(NSNumber *)collectionId;
-(void)loadCollectionDataWithCategoryId:(NSNumber *)musicCateId;
@end
