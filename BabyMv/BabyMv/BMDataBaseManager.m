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


#define DB_VER 5
#define DB_NAME @"babymv.sqlite"
#define DB_DIR  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"database"]
#define DB_PATH  [NSString stringWithFormat:@"%@/%@", DB_DIR, DB_NAME]

@interface BMDataBaseManager ()
@property(nonatomic, strong)FMDatabaseQueue* dbQueue;
@property(nonatomic, strong)NSSet* historyMusicIds;
@property(nonatomic, strong)NSSet* favedMusicCollectionIds;
@property(nonatomic, strong)NSSet* downloadedMusicIds;
@property(nonatomic, strong)NSSet* favedCartoonCollectionIds;
@property(nonatomic, strong)NSSet* downloadedCartoonIds;
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
        
#warning  数据库升级
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
        if (version != DB_VER) {
            [_dbQueue close];
            NSError* err = nil;
            [[NSFileManager defaultManager] removeItemAtPath:DB_PATH error:&err];
            dbExist = NO;
            if (err) {
                NSLog(@"数据库升级error = %@", err);
                dbExist = YES;
            }
        }

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
    }
    return self;
}


-(void) delUnuseUserMsgs:(FMDatabase *)db
{
    [db executeUpdate:@"delete from MusicCollection where IsFaved=0"];
    [db executeUpdate:@"delete from MusicList where IsDowned=0 and LastListeningTime=0"];
    [db executeUpdate:@"delete from CartoonCollection where IsFaved=0"];
    [db executeUpdate:@"delete from CartoonList where IsDowned=0"];
}
-(void) dropUnuseTables:(FMDatabase *)db
{
    [db executeUpdate:@"drop table MusicCate"];
    [db executeUpdate:@"drop table CartoonCate"];
}
-(void) backupUserDB:(FMDatabase *)db tableNames:(NSArray *)tableNames
{
    for (NSString* tableName in tableNames) {
        NSString* sqlStr = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_bak", tableName, tableName];
        [db executeUpdate:sqlStr];
    }
}
-(void) restoreUserMessage:(FMDatabase *)db from:(NSString*)fromTable to:(NSString*)toTable
{
    FMResultSet* rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@",fromTable]];
    NSString* columnStr = nil;
    if ([rs next]) {
        int columnCount = rs.columnCount;
        NSMutableArray* columnList = [[NSMutableArray alloc] initWithCapacity:columnCount];
        for (int index = 0; index < columnCount; index++) {
            [columnList addObject:[rs columnNameForIndex:index]];
        }
        columnStr = [columnList componentsJoinedByString:@","];
    }
    [rs close];
    if (!columnStr) {
        return;
    }
    [db executeUpdate:[NSString stringWithFormat:@"insert into %@ (%@) select %@ from %@",toTable,columnStr,columnStr,fromTable]];
    if([db hadError]) {
    }
}

-(NSArray *)createDBStr {
    return @[@"CREATE TABLE MusicCate(Rid integer PRIMARY KEY NOT NULL, Name text, Artist text, Url text, Time unsigned DEFAULT 0, BindingCollectionId unsigned DEFAULT 0, ExtraContent text, ExtraProperty text)",
             @"CREATE TABLE MusicCollection(Rid integer PRIMARY KEY NOT NULL, CateId integer, Name text, Artist text, Url text, Time unsigned DEFAULT 0, IsFaved integer DEFAULT 0, FavedTime unsigned DEFAULT 0, ExtraContent text, ExtraProperty text)",
             @"CREATE TABLE MusicList(Rid integer PRIMARY KEY NOT NULL, CollectionId integer, Name text, Artist text, Url text, Time unsigned DEFAULT 0, ListenCount integer DEFAULT 0, IsDowned integer DEFAULT 0, DownloadTime unsigned DEFAULT 0, LastListeningTime unsigned DEFAULT 0, ExtraContent text, ExtraProperty text)",
             @"CREATE TABLE CartoonCate(Rid integer PRIMARY KEY NOT NULL, Name text, Artist text, Url text, Time unsigned DEFAULT 0, BindingCollectionId unsigned DEFAULT 0, ExtraContent text, ExtraProperty text)",
             @"CREATE TABLE CartoonCollection(Rid integer PRIMARY KEY NOT NULL, CateId integer, Name text, Artist text, Url text, Time unsigned DEFAULT 0, IsFaved integer DEFAULT 0, FavedTime unsigned DEFAULT 0, ExtraContent text, ExtraProperty text)",
             @"CREATE TABLE CartoonList(Rid integer PRIMARY KEY NOT NULL, CollectionId integer, Name text, Artist text, Url text, Time unsigned DEFAULT 0, PicUrl text, ListenCount integer DEFAULT 0, IsDowned integer DEFAULT 0, DownloadTime unsigned DEFAULT 0, LastListeningTime unsigned DEFAULT 0, ExtraContent text, ExtraProperty text)"
             ];
}

#pragma mark - cache
-(NSSet *)historyMusicIds {
    if (!_historyMusicIds) {
        NSArray* historyArr = [self getListenMusicList];
        NSMutableArray* historyMusicIds = [NSMutableArray new];
        for (BMListDataModel* listData in historyArr) {
            if ([listData.LastListeningTime intValue] > 0) {
                [historyMusicIds addObject:listData.Rid];
            }
        }
        _historyMusicIds = [NSSet setWithArray:historyMusicIds];
    }
    return _historyMusicIds;
}
-(NSSet *)favedMusicCollectionIds {
    if (!_favedMusicCollectionIds) {
        NSArray* favedArr = [self getFavoriteMusicCollections];
        NSMutableArray* favedMusicIds = [NSMutableArray new];
        for (BMCollectionDataModel* collectionData in favedArr) {
            if ([collectionData.IsFaved intValue]) {
                [favedMusicIds addObject:collectionData.Rid];
            }
        }
        _favedMusicCollectionIds = [NSSet setWithArray:favedMusicIds];
    }
    return _favedMusicCollectionIds;
}
-(NSSet *)downloadedMusicIds {
    if (!_downloadedMusicIds) {
        NSArray* downloadedArr = [self getDownloadedMusicList];
        NSMutableArray* downloadedMusicIds = [NSMutableArray new];
        for (BMListDataModel* listData in downloadedArr) {
            if ([listData.IsDowned intValue]) {
                [downloadedMusicIds addObject:listData.Rid];
            }
        }
        _downloadedMusicIds = [NSSet setWithArray:downloadedMusicIds];
    }
    return _downloadedMusicIds;
}
-(NSSet *)favedCartoonCollectionIds {
    if (!_favedCartoonCollectionIds) {
        NSArray* favedArr = [self getFavoriteCartoonCollections];
        NSMutableArray* favedCartoonIds = [NSMutableArray new];
        for (BMCartoonCollectionDataModel* collectionData in favedArr) {
            if ([collectionData.IsFaved intValue]) {
                [favedCartoonIds addObject:collectionData.Rid];
            }
        }
        _favedCartoonCollectionIds = [NSSet setWithArray:favedCartoonIds];
    }
    return _favedCartoonCollectionIds;
}
-(NSSet *)downloadedCartoonIds {
    if (!_downloadedCartoonIds) {
        NSArray* downloadedArr = [self getDownloadedCartoonList];
        NSMutableArray* downloadedCartoonIds = [NSMutableArray new];
        for (BMCartoonListDataModel* listData in downloadedArr) {
            if ([listData.IsDowned intValue]) {
                [downloadedCartoonIds addObject:listData.Rid];
            }
        }
        _downloadedCartoonIds = [NSSet setWithArray:downloadedCartoonIds];
    }
    return _downloadedCartoonIds;
}

#pragma mark - music分类
-(NSArray *)getAllCateIds {
    __block NSMutableArray* resArr = [NSMutableArray new];
    __block NSMutableSet* resSet = [NSMutableSet new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select Rid from MusicCate"];
        while ([resultSet next]) {
            NSNumber* numId = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            if (![resSet containsObject:numId]) {
                [resSet addObject:numId];
                [resArr addObject:numId];
            }
        }
    }];
    return resArr;
}

-(NSArray *)getAllMusicCate {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from MusicCate order by Rid asc"];
        while ([query_result next]) {
            BMDataModel* cur_item = [[BMDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.BindingCollectionId = [NSNumber numberWithInt:[query_result intForColumn:@"BindingCollectionId"]];
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
//            [db executeUpdate:@"replace into MusicCate set Name=?, Artist=?, Url=?, Time=? where Rid=?",cate.Name, cate.Artist, cate.Url, cate.Time, cate.Rid];
            [db executeUpdate:@"replace into MusicCate(Name, Artist, Url, Time, Rid) values (?,?,?,?,?)",cate.Name, cate.Artist, cate.Url, cate.Time, cate.Rid];
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(BOOL)updateMusicCateId:(NSNumber *)cateId withBindingCollectionId:(NSNumber *)collectionId {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicCate set BindingCollectionId=? where Rid = ?", collectionId, cateId];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            result = NO;
        }
    }];
    return result;
}

#pragma mark - music合集
-(NSArray *)getFavoriteMusicCollections {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from MusicCollection where IsFaved=1 order by Rid asc"];
        while ([query_result next]) {
            BMCollectionDataModel* cur_item = [[BMCollectionDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.CateId = [NSNumber numberWithInt:[query_result intForColumn:@"CateId"]];
            cur_item.IsFaved = [NSNumber numberWithInt:[query_result intForColumn:@"IsFaved"]];
            cur_item.FavedTime = [NSNumber numberWithLongLong:[query_result unsignedLongLongIntForColumn:@"FavedTime"]];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(BMCollectionDataModel *)musicCollectionById:(NSNumber *) CollectionId {
    __block BMCollectionDataModel* cur_item = [[BMCollectionDataModel alloc] init];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from MusicCollection where Rid=?", CollectionId];
        if ([query_result next]) {
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.CateId = [NSNumber numberWithInt:[query_result intForColumn:@"CateId"]];
            cur_item.IsFaved = [NSNumber numberWithInt:[query_result intForColumn:@"IsFaved"]];
            cur_item.FavedTime = [NSNumber numberWithLongLong:[query_result unsignedLongLongIntForColumn:@"FavedTime"]];
        }
        [query_result close];
    }];
    return cur_item;
}

-(BOOL)IsMusicCollectionFaved:(NSNumber *) CollectionId {
    __block BOOL IsFaved = NO;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select IsFaved from MusicCollection where Rid=?", CollectionId];
        while ([resultSet next]) {
            IsFaved = [resultSet intForColumn:@"IsFaved"];
        }
    }];
    return IsFaved;
}

-(NSArray *)getAllCollectionIds {
    __block NSMutableArray* resArr = [NSMutableArray new];
    __block NSMutableSet* resSet = [NSMutableSet new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select Rid from MusicCollection"];
        while ([resultSet next]) {
            NSNumber* numId = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            if (![resSet containsObject:numId]) {
                [resSet addObject:numId];
                [resArr addObject:numId];
            }
        }
    }];
    return resArr;
}

-(NSArray *)getAllMusicCollection {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from MusicCollection order by Rid asc"];
        while ([query_result next]) {
            BMCollectionDataModel* cur_item = [[BMCollectionDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.CateId = [NSNumber numberWithInt:[query_result intForColumn:@"CateId"]];
            cur_item.IsFaved = [NSNumber numberWithInt:[query_result intForColumn:@"IsFaved"]];
            cur_item.FavedTime = [NSNumber numberWithLongLong:[query_result unsignedLongLongIntForColumn:@"FavedTime"]];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(NSArray *)getMusicCollectionByCateId:(NSNumber *)cateId {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from MusicCollection where CateId=?", cateId];
        while ([query_result next]) {
            BMCollectionDataModel* cur_item = [[BMCollectionDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.CateId = [NSNumber numberWithInt:[query_result intForColumn:@"CateId"]];
            cur_item.IsFaved = [NSNumber numberWithInt:[query_result intForColumn:@"IsFaved"]];
            cur_item.FavedTime = [NSNumber numberWithLongLong:[query_result unsignedLongLongIntForColumn:@"FavedTime"]];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(BOOL)addMusicCollectionArr:(NSArray *) arr {
    NSSet* favedMusicCollectionIds = self.favedMusicCollectionIds;
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMCollectionDataModel* collection in arr) {
            if ([favedMusicCollectionIds containsObject:collection.Rid]) {
                [db executeUpdate:@"update MusicCollection set Name=?, Artist=?, Url=?, Time=?, CateId=? where Rid=?",collection.Name, collection.Artist, collection.Url, collection.Time, collection.CateId, collection.Rid];
            } else {
                [db executeUpdate:@"replace into MusicCollection(Name, Artist, Url, Time, CateId, Rid) values (?,?,?,?,?,?)",collection.Name, collection.Artist, collection.Url, collection.Time, collection.CateId, collection.Rid];
            }
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
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
-(NSArray *)getDownloadedMusicList {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from MusicList where IsDowned=1 order by Rid asc"];
        while ([resultSet next]) {
            BMListDataModel* listData = [BMListDataModel new];
            listData.Rid = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.Time = [NSNumber numberWithLongLong:[resultSet longLongIntForColumn:@"Time"]];
            listData.CollectionId = [NSNumber numberWithInt:[resultSet intForColumn:@"CollectionId"]];
            listData.ListenCount = [NSNumber numberWithInt:[resultSet intForColumn:@"ListenCount"]];
            listData.IsDowned = [NSNumber numberWithInt:[resultSet intForColumn:@"IsDowned"]];
            listData.DownloadTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"DownloadTime"]];
            listData.LastListeningTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]];
            [resArr addObject:listData];
        }
    }];
    return resArr;
}

-(NSArray *)getListenMusicList {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from MusicList where LastListeningTime>? order by Rid asc", [NSNumber numberWithLongLong:NSTimeIntervalSince1970]];
        while ([resultSet next]) {
            BMListDataModel* listData = [BMListDataModel new];
            listData.Rid = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.Time = [NSNumber numberWithLongLong:[resultSet longLongIntForColumn:@"Time"]];
            listData.CollectionId = [NSNumber numberWithInt:[resultSet intForColumn:@"CollectionId"]];
            listData.ListenCount = [NSNumber numberWithInt:[resultSet intForColumn:@"ListenCount"]];
            listData.IsDowned = [NSNumber numberWithInt:[resultSet intForColumn:@"IsDowned"]];
            listData.DownloadTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"DownloadTime"]];
            listData.LastListeningTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]];
            [resArr addObject:listData];
        }
    }];
    return resArr;
}

-(NSArray *)getAllMusicList {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from MusicList order by Rid asc"];
        while ([resultSet next]) {
            BMListDataModel* listData = [BMListDataModel new];
            listData.Rid = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.Time = [NSNumber numberWithLongLong:[resultSet longLongIntForColumn:@"Time"]];
            listData.CollectionId = [NSNumber numberWithInt:[resultSet intForColumn:@"CollectionId"]];
            listData.ListenCount = [NSNumber numberWithInt:[resultSet intForColumn:@"ListenCount"]];
            listData.IsDowned = [NSNumber numberWithInt:[resultSet intForColumn:@"IsDowned"]];
            listData.DownloadTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"DownloadTime"]];
            listData.LastListeningTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]];
            [resArr addObject:listData];
        }
    }];
    return resArr;
}

-(NSArray *)getMusicListByCollectionId:(NSNumber *)collectionId {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from MusicList where CollectionId=?", collectionId];
        while ([resultSet next]) {
            BMListDataModel* listData = [BMListDataModel new];
            listData.Rid = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.Time = [NSNumber numberWithLongLong:[resultSet longLongIntForColumn:@"Time"]];
            listData.CollectionId = [NSNumber numberWithInt:[resultSet intForColumn:@"CollectionId"]];
            listData.ListenCount = [NSNumber numberWithInt:[resultSet intForColumn:@"ListenCount"]];
            listData.IsDowned = [NSNumber numberWithInt:[resultSet intForColumn:@"IsDowned"]];
            listData.DownloadTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"DownloadTime"]];
            listData.LastListeningTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]];
            [resArr addObject:listData];
        }
    }];
    return resArr;
}

-(BOOL)addMusicListArr:(NSArray *)arr {
    NSSet* downloadedMusicIds = self.downloadedMusicIds;
    NSSet* historyMusicIds = self.historyMusicIds;
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMListDataModel* list in arr) {
            if ([downloadedMusicIds containsObject:list.Rid] || [historyMusicIds containsObject:list.Rid]) {
                [db executeUpdate:@"update MusicList set CollectionId=?, Name=?, Artist=?, Url=?, Time=? where Rid=?", list.CollectionId, list.Name, list.Artist, list.Url, list.Time, list.Rid];
            } else {
                [db executeUpdate:@"replace into MusicList(Rid, CollectionId, Name, Artist, Url, Time) values (?,?,?,?,?,?)", list.Rid, list.CollectionId, list.Name, list.Artist, list.Url, list.Time];
            }
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(void)updateMusicList:(BMListDataModel *)list {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicList set ListenCount=?, IsDowned=?, DownloadTime=?, LastListeningTime=? where Rid=?", list.ListenCount, list.IsDowned, list.DownloadTime, list.LastListeningTime, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

-(BOOL)downLoadMusicList:(BMListDataModel *)list {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update MusicList set IsDowned=?, DownloadTime=? where Rid=?", list.IsDowned, list.DownloadTime, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            result = NO;
        }
    }];
    return result;
}

-(void)listenMusicListArr:(NSArray *)arr {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMListDataModel* list in arr) {
            [db executeUpdate:@"update MusicList set LastListeningTime=? where Rid=?", list.LastListeningTime, list.Rid];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
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

#pragma mark - cartoon分类
-(NSArray *)getAllCartoonCateIds {
    __block NSMutableArray* resArr = [NSMutableArray new];
    __block NSMutableSet* resSet = [NSMutableSet new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select Rid from CartoonCate"];
        while ([resultSet next]) {
            NSNumber* numId = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            if (![resSet containsObject:numId]) {
                [resSet addObject:numId];
                [resArr addObject:numId];
            }
        }
    }];
    return resArr;
}

-(NSArray *)getAllCartoonCate {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from CartoonCate order by Rid asc"];
        while ([query_result next]) {
            BMDataModel* cur_item = [[BMDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.BindingCollectionId = [NSNumber numberWithInt:[query_result intForColumn:@"BindingCollectionId"]];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(BOOL)addCartoonCateArr:(NSArray *) arr {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMDataModel* cate in arr) {
            [db executeUpdate:@"replace into CartoonCate(Name, Artist, Url, Time, Rid) values (?,?,?,?,?)",cate.Name, cate.Artist, cate.Url, cate.Time, cate.Rid];
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(BOOL)updateCartoonCateId:(NSNumber *)cateId withBindingCollectionId:(NSNumber *)collectionId {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update CartoonCate set BindingCollectionId=? where Rid = ?", collectionId, cateId];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            result = NO;
        }
    }];
    return result;
}

#pragma mark - cartoon合集
-(NSArray *)getFavoriteCartoonCollections {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from CartoonCollection where IsFaved=1 order by Rid asc"];
        while ([query_result next]) {
            BMCartoonCollectionDataModel* cur_item = [[BMCartoonCollectionDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.CateId = [NSNumber numberWithInt:[query_result intForColumn:@"CateId"]];
            cur_item.IsFaved = [NSNumber numberWithInt:[query_result intForColumn:@"IsFaved"]];
            cur_item.FavedTime = [NSNumber numberWithLongLong:[query_result unsignedLongLongIntForColumn:@"FavedTime"]];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(BOOL)IsCartoonCollectionFaved:(NSNumber *) CollectionId {
    __block BOOL IsFaved = NO;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select IsFaved from CartoonCollection where Rid=?", CollectionId];
        while ([resultSet next]) {
            IsFaved = [resultSet intForColumn:@"IsFaved"];
        }
    }];
    return IsFaved;
}

-(NSArray *)getAllCartoonCollectionIds {
    __block NSMutableArray* resArr = [NSMutableArray new];
    __block NSMutableSet* resSet = [NSMutableSet new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select Rid from CartoonCollection"];
        while ([resultSet next]) {
            NSNumber* numId = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            if (![resSet containsObject:numId]) {
                [resSet addObject:numId];
                [resArr addObject:numId];
            }
        }
    }];
    return resArr;
}

-(NSArray *)getAllCartoonCollection {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from CartoonCollection order by Rid asc"];
        while ([query_result next]) {
            BMCartoonCollectionDataModel* cur_item = [[BMCartoonCollectionDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.CateId = [NSNumber numberWithInt:[query_result intForColumn:@"CateId"]];
            cur_item.IsFaved = [NSNumber numberWithInt:[query_result intForColumn:@"IsFaved"]];
            cur_item.FavedTime = [NSNumber numberWithLongLong:[query_result unsignedLongLongIntForColumn:@"FavedTime"]];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(NSArray *)getCartoonCollectionByCateId:(NSNumber *)cateId {
    __block NSMutableArray *resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* query_result = [db executeQuery:@"select * from CartoonCollection where CateId=?", cateId];
        while ([query_result next]) {
            BMCartoonCollectionDataModel* cur_item = [[BMCartoonCollectionDataModel alloc] init];
            cur_item.Rid = [NSNumber numberWithInt:[query_result intForColumn:@"Rid"]];
            cur_item.Name = [query_result stringForColumn:@"Name"];
            cur_item.Artist = [query_result stringForColumn:@"Artist"];
            cur_item.Url = [query_result stringForColumn:@"Url"];
            cur_item.Time = [NSNumber numberWithLongLong:[query_result longLongIntForColumn:@"Time"]];
            cur_item.CateId = [NSNumber numberWithInt:[query_result intForColumn:@"CateId"]];
            cur_item.IsFaved = [NSNumber numberWithInt:[query_result intForColumn:@"IsFaved"]];
            cur_item.FavedTime = [NSNumber numberWithLongLong:[query_result unsignedLongLongIntForColumn:@"FavedTime"]];
            [resArr addObject:cur_item];
        }
        [query_result close];
    }];
    return resArr;
}

-(BOOL)addCartoonCollectionArr:(NSArray *) arr {
    NSSet* favedCartoonCollectionIds = self.favedCartoonCollectionIds;
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMCartoonCollectionDataModel* collection in arr) {
            if ([favedCartoonCollectionIds containsObject:collection.Rid]) {
                [db executeUpdate:@"update CartoonCollection set Name=?, Artist=?, Url=?, Time=?, CateId=? where Rid = ?",collection.Name, collection.Artist, collection.Url, collection.Time, collection.CateId, collection.Rid];
            } else {
                [db executeUpdate:@"replace into CartoonCollection(Name, Artist, Url, Time, CateId, Rid) values (?,?,?,?,?,?)",collection.Name, collection.Artist, collection.Url, collection.Time, collection.CateId, collection.Rid];
            }
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(void)favCartoonCollection:(BMCollectionDataModel *) collection {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update CartoonCollection set IsFaved=?, FavedTime=? where Rid = ?",collection.IsFaved, collection.FavedTime, collection.Rid];
        if ([db hadError])
        {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

#pragma mark - cartoon list
-(NSArray *)getDownloadedCartoonList {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from CartoonList where IsDowned=1 order by Rid asc"];
        while ([resultSet next]) {
            BMCartoonListDataModel* listData = [BMCartoonListDataModel new];
            listData.Rid = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.Time = [NSNumber numberWithLongLong:[resultSet longLongIntForColumn:@"Time"]];
            listData.PicUrl = [resultSet stringForColumn:@"PicUrl"];
            listData.CollectionId = [NSNumber numberWithInt:[resultSet intForColumn:@"CollectionId"]];
            listData.ListenCount = [NSNumber numberWithInt:[resultSet intForColumn:@"ListenCount"]];
            listData.IsDowned = [NSNumber numberWithInt:[resultSet intForColumn:@"IsDowned"]];
            listData.DownloadTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"DownloadTime"]];
            listData.LastListeningTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]];
            [resArr addObject:listData];
        }
    }];
    return resArr;
}

-(NSArray *)getAllCartoonList {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from CartoonList order by Rid asc"];
        while ([resultSet next]) {
            BMCartoonListDataModel* listData = [BMCartoonListDataModel new];
            listData.Rid = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.Time = [NSNumber numberWithLongLong:[resultSet longLongIntForColumn:@"Time"]];
            listData.PicUrl = [resultSet stringForColumn:@"PicUrl"];
            listData.CollectionId = [NSNumber numberWithInt:[resultSet intForColumn:@"CollectionId"]];
            listData.ListenCount = [NSNumber numberWithInt:[resultSet intForColumn:@"ListenCount"]];
            listData.IsDowned = [NSNumber numberWithInt:[resultSet intForColumn:@"IsDowned"]];
            listData.DownloadTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"DownloadTime"]];
            listData.LastListeningTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]];
            [resArr addObject:listData];
        }
    }];
    return resArr;
}

-(NSArray *)getCartoonListByCollectionId:(NSNumber *)collectionId {
    __block NSMutableArray* resArr = [NSMutableArray new];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* resultSet = [db executeQuery:@"select * from CartoonList where CollectionId=?", collectionId];
        while ([resultSet next]) {
            BMCartoonListDataModel* listData = [BMCartoonListDataModel new];
            listData.Rid = [NSNumber numberWithInt:[resultSet intForColumn:@"Rid"]];
            listData.Name = [resultSet stringForColumn:@"Name"];
            listData.Artist = [resultSet stringForColumn:@"Artist"];
            listData.Url = [resultSet stringForColumn:@"Url"];
            listData.Time = [NSNumber numberWithLongLong:[resultSet longLongIntForColumn:@"Time"]];
            listData.PicUrl = [resultSet stringForColumn:@"PicUrl"];
            listData.CollectionId = [NSNumber numberWithInt:[resultSet intForColumn:@"CollectionId"]];
            listData.ListenCount = [NSNumber numberWithInt:[resultSet intForColumn:@"ListenCount"]];
            listData.IsDowned = [NSNumber numberWithInt:[resultSet intForColumn:@"IsDowned"]];
            listData.DownloadTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"DownloadTime"]];
            listData.LastListeningTime = [NSNumber numberWithLongLong:[resultSet unsignedLongLongIntForColumn:@"LastListeningTime"]];
            [resArr addObject:listData];
        }
    }];
    return resArr;
}

-(BOOL)addCartoonListArr:(NSArray *)arr {
    NSSet* downloadedCartoonIds = self.downloadedCartoonIds;
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (BMCartoonListDataModel* list in arr) {
            if ([downloadedCartoonIds containsObject:list.Rid]) {
                [db executeUpdate:@"update CartoonList set CollectionId=?, Name=?, Artist=?, Url=?, Time=?, PicUrl=? where Rid=?", list.CollectionId, list.Name, list.Artist, list.Url, list.Time, list.PicUrl, list.Rid];
            } else {
                [db executeUpdate:@"replace into CartoonList(Rid, CollectionId, Name, Artist, Url, Time, PicUrl) values (?,?,?,?,?,?,?)", list.Rid, list.CollectionId, list.Name, list.Artist, list.Url, list.Time, list.PicUrl];
            }
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                result = NO;
            }
        }
    }];
    return result;
}

-(void)updateCartoonList:(BMCartoonListDataModel *)list {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update CartoonList set ListenCount=?, IsDowned=?, DownloadTime=?, LastListeningTime=? where Rid=?", list.ListenCount, list.IsDowned, list.DownloadTime, list.LastListeningTime, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

-(BOOL)downLoadCartoonList:(BMCartoonListDataModel *)list {
    __block BOOL result = YES;;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update CartoonList set IsDowned=?, DownloadTime=? where Rid=?", list.IsDowned, list.DownloadTime, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            result = NO;
        }
    }];
    return result;
}

-(void)openCartoonList:(BMCartoonListDataModel *)list {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update CartoonList set LastListeningTime=? where Rid=?", list.LastListeningTime, list.Rid];
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

@end
