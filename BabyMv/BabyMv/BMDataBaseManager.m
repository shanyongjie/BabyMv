//
//  BMDataBaseManager.m
//  BabyMv
//
//  Created by ma on 2/8/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMDataBaseManager.h"
#import "BMDataModel.h"

#import <FMDB.h>
#import <FMDatabaseQueue.h>


#define DB_VER 1
#define DB_NAME @"babymv.sqlite"
#define DB_DIR  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"database"]
#define DB_PATH  [NSString stringWithFormat:@"%@/%@", DB_DIR, DB_NAME]

@interface BMDataBaseManager ()
@property(nonatomic, strong)FMDatabaseQueue* dbQueue;
@end

@implementation BMDataBaseManager

+(instancetype)sharedInstance {
    static BMDataBaseManager* BMDBInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BMDBInstance = [BMDataBaseManager new];
    });
    return BMDBInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        BOOL dbExist = [[NSFileManager defaultManager] fileExistsAtPath:DB_PATH];
        BOOL dirExist = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:DB_DIR isDirectory:&dirExist]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:DB_DIR withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        NSLog(@"%@", DB_PATH);
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:DB_PATH];
        if (!dbExist) {
            [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                [db setShouldCacheStatements:YES];
                for (NSString* str in [self createDBStr]) {
                    [db executeUpdate:str];
                }
                NSString *sql = [NSString stringWithFormat:@"PRAGMA user_version = %d",DB_VER];
                [db executeUpdate:sql];
                if([db hadError]) {
                    *rollback = YES;
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
            }];
        } else {
            
        }
        __block NSInteger version = 0;
        [_dbQueue inDatabase:^(FMDatabase * db){
            FMResultSet *rs = [db executeQuery:@"PRAGMA user_version"];
            if ([rs next])
            {
                version = [rs intForColumnIndex:0];
            }
            [rs close];
            
            NSLog(@"user_version-------:%ld", (long)version);
        }];
    }
    return self;
}

-(NSArray *)createDBStr {
    return @[@"CREATE TABLE MusicCate(Rid integer PRIMARY KEY NOT NULL, Name text, Artist text, Url text)",
             @"CREATE TABLE MusicCollection(Rid integer PRIMARY KEY NOT NULL, CateId integer, Name text, Artist text, Url text, IsFaved integer DEFAULT 0, FavedTime unsigned DEFAULT 0)",
             @"CREATE TABLE MusicList(Rid integer PRIMARY KEY NOT NULL, CollectionId integer, Name text, Artist text, Url text, ListenCount integer DEFAULT 0, IsDowned integer DEFAULT 0, DownloadTime unsigned DEFAULT 0, LastListeningTime unsigned DEFAULT 0)",
             @"CREATE TABLE CartoonCate(Rid integer PRIMARY KEY NOT NULL, Name text, Artist text, Url text)",
             @"CREATE TABLE CartoonCollection(Rid integer PRIMARY KEY NOT NULL, CateId integer, Name text, Artist text, Url text, IsFaved integer DEFAULT 0, FavedTime unsigned DEFAULT 0)",
             @"CREATE TABLE CartoonList(Rid integer PRIMARY KEY NOT NULL, CollectionId integer, Name text, Artist text, Url text, ListenCount integer DEFAULT 0, IsDowned integer DEFAULT 0, DownloadTime unsigned DEFAULT 0, LastListeningTime unsigned DEFAULT 0)"
             ];
}

#pragma mark - 分类
-(NSArray *)getAllMusicCate {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from MusicCate order by Rid asc"];
        while ([query_result next]) {
            BMDataModel* cur_item = [[BMDataModel alloc] init];
            cur_item.Rid = @([query_result intForColumn:@"Rid"]);
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(BOOL)addMusicCateArr:(NSArray *) arr {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMDataModel* cate in arr) {
            [db executeUpdate:@"replace into MusicCate(Name, Artist, Url, Rid) values (?,?,?,?)",cate.Name, cate.Artist, cate.Url, cate.Rid];
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(BOOL)addMusicCate:(BMDataModel *) cate {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"replace into MusicCate(Name, Artist, Url, Rid) values (?,?,?,?)",cate.Name, cate.Artist, cate.Url, cate.Rid];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            result = NO;
        }
    }];
    return result;
}

-(void)updateMusicCate:(BMDataModel *) cate {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicCate set Name=?, Artist=?, Url=? where Rid = ?",cate.Name, cate.Artist, cate.Url, cate.Rid];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

#pragma mark - 合集
-(NSArray *)getAllMusicCollection {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from MusicCollection order by Rid asc"];
        while ([query_result next]) {
            BMCollectionDataModel* cur_item = [[BMCollectionDataModel alloc] init];
            cur_item.Rid = @([query_result intForColumn:@"Rid"]);
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.IsFaved = @([query_result intForColumn:@"IsFaved"]);
            cur_item.FavedTime = @([query_result unsignedLongLongIntForColumn:@"FavedTime"]);
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(BOOL)addMusicCollectionArr:(NSArray *) arr {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMCollectionDataModel* collection in arr) {
            [db executeUpdate:@"replace into MusicCollection(Name, Artist, Url, Rid) values (?,?,?,?)",collection.Name, collection.Artist, collection.Url, collection.Rid];
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(BOOL)addMusicCollection:(BMCollectionDataModel *) collection {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"replace into MusicCollection(Name, Artist, Url, Rid) values (?,?,?,?)",collection.Name, collection.Artist, collection.Url, collection.Rid];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            result = NO;
        }
    }];
    return result;
}

-(void)updateMusicCollection:(BMCollectionDataModel *) collection {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicCollection set Name=?, Artist=?, Url=? where Rid = ?",collection.Name, collection.Artist, collection.Url, collection.Rid];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

-(void)favMusicCollection:(BMCollectionDataModel *) collection {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicCollection set IsFaved=?, FavedTime=? where Rid = ?",collection.IsFaved, collection.FavedTime, collection.Rid];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

#pragma mark - music list
-(NSArray *)getAllMusicList {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from MusicList order by Rid asc"];
        while ([resultSet next]) {
            BMListDataModel* listData = [BMListDataModel new];
            listData.Rid = @([resultSet intForColumn:@"Rid"]);
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.ListenCount = @([resultSet intForColumn:@"ListenCount"]);
            listData.IsDowned = @([resultSet intForColumn:@"IsDowned"]);
            listData.DownloadTime = @([resultSet unsignedLongLongIntForColumn:@"DownloadTime"]);
            listData.LastListeningTime = @([resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]);
        }
    }];
    return resArr;
}

-(BOOL)addMusicListArr:(NSArray *)arr {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMListDataModel* list in arr) {
            [db executeUpdate:@"replace into MusicList(Rid, CollectionId, Name, Artist, Url) values (?,?,?,?,?)", list.Rid, list.CollectionId, list.Name, list.Artist, list.Url];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(BOOL)addMusicList:(BMListDataModel *)list {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"replace into MusicList(Rid, CollectionId, Name, Artist, Url) values (?,?,?,?,?)", list.Rid, list.CollectionId, list.Name, list.Artist, list.Url];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            result = NO;
        }
    }];
    return result;
}

-(void)updateMusicList:(BMListDataModel *)list {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicList set CollectionId=?, Name=?, Artist=?, Url=? where Rid=?", list.CollectionId, list.Name, list.Artist, list.Url, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

-(void)downLoadMusicList:(BMListDataModel *)list {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicList set IsDowned=?, DownloadTime=? where Rid=?", list.IsDowned, list.DownloadTime, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

-(void)listenMusicList:(BMListDataModel *)list {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicList set LastListeningTime=? where Rid=?", list.LastListeningTime, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}



@end
