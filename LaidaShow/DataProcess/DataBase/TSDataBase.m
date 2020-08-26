//
//  TSDataBase.m
//  ThreeShow
//
//  Created by hitomedia on 03/05/2018.
//  Copyright © 2018 deepai. All rights reserved.
//

#import "TSDataBase.h"
#import <sqlite3.h>
#import "TSUserModel.h"
#import "NSString+Ext.h"
#import "SDImageCache.h"

static NSString * const DBUserModelKey = @"DBUserModelKey";
static NSString * const tableRecentQueryTrainLate = @"trq_train_late";//历史搜索的表

static NSString * const DBLocalWork = @"DBLocalWork";        //本地作品数据库
static NSString * const tableLocalWork = @"table_local_work";//本地作品的表

@interface TSDataBase()

@property (nonatomic, assign) sqlite3 *recentQueryTrainLateDB;
@property (nonatomic, assign) sqlite3 *localWorkDB;
@end

@implementation TSDataBase{
    TSUserModel *_userModel;
}

+(TSDataBase *)sharedDataBase{
    static TSDataBase *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db = [TSDataBase new];
    });
    
    return db;
}

#pragma mark - Cache

//清除本地缓存
- (void)clearCache{
    [self cleanCaches:[self getImgCacheDir]];
}

// 单位M
- (CGFloat)cacheSize{
    
    return [self folderSizeAtPath:[self getImgCacheDir]];
}

- (void)cleanCaches:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    //SDWebImage的清除功能
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        
    }];
    [[SDImageCache sharedImageCache] clearMemory];
}

- (CGFloat)folderSizeAtPath:(NSString *)path{
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 目录下的文件计算大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            BOOL isDir = NO;
            BOOL exist = [manager fileExistsAtPath:absolutePath isDirectory:&isDir];
            
            if( exist ){
     
                size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
            }
        }
    }
    
    //SDWebImage的缓存计算
    size += [[SDImageCache sharedImageCache] getSize];
    // 将大小转化为M,size单位b,转，KB,MB除以两次1024
    return size / 1024.0 / 1024.0;
}


#pragma mark - User

- (TSUserModel *)userModel{
    if( _userModel == nil ){
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:DBUserModelKey];
        if( [data isKindOfClass:[NSData class]] ){
            _userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    
    if( [_userModel isKindOfClass:[TSUserModel class]] )
        return _userModel;
    
    return nil;
}

- (void)updateUserModel:(TSUserModel *)um{
    if( [um isKindOfClass:[TSUserModel class]] ){
        _userModel = um;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:um];
        if( data ){
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:DBUserModelKey];
        }
    }
}

- (void)removeUserModel{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DBUserModelKey];
    _userModel = nil;
}

#pragma mark - Recently TrainNum of LateTime Query

- (BOOL)insertHistorySearchWord:(NSString *)searchWord {
    if( [searchWord isKindOfClass:[NSString class]] ==NO )
        return NO;
    
    BOOL isExist = [self isExistInDataBase:self.recentQueryTrainLateDB tableName:tableRecentQueryTrainLate segmentName:@"name" value:searchWord];
    if( isExist )
        return YES;
    
    sqlite3_stmt *statement;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(name) VALUES(?)",tableRecentQueryTrainLate];
    int success = sqlite3_prepare(self.recentQueryTrainLateDB, [sql UTF8String], -1, &statement, NULL);
    if( success != SQLITE_OK ){
        return NO;
    }
    
    //绑定问号对应变量
    sqlite3_bind_text(statement, 1, [searchWord UTF8String], -1, SQLITE_TRANSIENT);
    
    //执行插入
    success = sqlite3_step(statement);
    //释放statement
    sqlite3_finalize(statement);
    
    if( success == SQLITE_ERROR )
        return NO;
    
    return YES;
}

- (NSArray<NSString *> *)historySearchDatas{
    NSMutableArray *arr = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ order by id DESC",tableRecentQueryTrainLate];
    sqlite3_stmt *statement;
    const char *err;
    
    if( sqlite3_prepare_v2(self.recentQueryTrainLateDB, [sql UTF8String], -1, &statement, &err) == SQLITE_OK){
        int i=0;
        while (sqlite3_step(statement) == SQLITE_ROW ) {
            
//            if( i == count && count > 0){
//                break;
//            }
            
            char *name = (char*)sqlite3_column_text(statement, 1);
            if( name != NULL ){
                [arr addObject:[NSString stringWithUTF8String:name]];
            }
            
            i++;
        }
    }
    
    sqlite3_finalize(statement);
    if( arr.count <=0  )
        arr = nil;
    return arr;
}

- (BOOL)deleteHistorySearchDatas{
    return [self deleteDataWithMaxId:-1 table:tableRecentQueryTrainLate
                            dataBase:self.recentQueryTrainLateDB];
}

- (BOOL)deleteHistoryWithText:(NSString*)text{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE name='%@'",tableRecentQueryTrainLate,text];
    sqlite3_stmt *statement ;
    int success = sqlite3_prepare_v2(self.recentQueryTrainLateDB, [sql UTF8String], -1, &statement, NULL);
    if( success != SQLITE_OK ){
        return NO;
    }
    
    //执行
    char *errMsg = nil;
    success = sqlite3_exec(self.recentQueryTrainLateDB, [sql UTF8String], NULL, NULL, &errMsg);
    //释放statement
    sqlite3_finalize(statement);
    
    return (success == SQLITE_OK);
}

#pragma mark - 视频作品的本地缓存

/**
 获取本地作品
 
 @param pageIndex 第几页
 @param isVideoWork 是否为视频作品
 @return 作品集合
 */
- (NSArray<TSWorkModel*>*)localWorkDatasWithPageIndex:(NSInteger)pageIndex isVideoWork:(BOOL)isVideoWork{
    return nil;
}
- (BOOL)insertLocalWorkModel:(TSWorkModel*)wm{
    return NO;
}
- (BOOL)updateLocalWorkModel:(TSWorkModel*)wm{
    return YES;
}
- (BOOL)deleteLocalWorkWithWorkId:(NSString*)wid{
    return YES;
}

#pragma mark - Properts
- (sqlite3 *)recentQueryTrainLateDB{
    if( !_recentQueryTrainLateDB ){
        NSString *sqlCreateTable = [NSString stringWithFormat:@"create table if not exists %@ (ID Integer PRIMARY KEY AUTOINCREMENT, name text)",tableRecentQueryTrainLate];
        _recentQueryTrainLateDB =[self createTableWithSql:sqlCreateTable
                                             dataBaseName:@"rq_station_trainlate.db"
                                                 dateBase:_recentQueryTrainLateDB]; //_recentQueryStationSaleTimeDB];
    }
    return _recentQueryTrainLateDB;
}

/** 作品缓存
 name 作品名称
 category 作品类别
 price 作品价格
 saleCount 月销量
 buyUrl 购买链接
 desc 作品描述
 audioPath 录音的路径
 musicName 音乐的名称
 originImgUrls 三维作品原图路径
 midImgUrls 三维作品去底时的中间图路径
 clearImgUrls 三维作品去底结果图路径
 videoLength 三维作品的生成的视频时长
 videoPath 视频作品的视频路径
 videoCover 视频作品的封面
 workType 作品类型，0三维作品，1视频作品
 */
- (sqlite3 *)localWorkDB{
    if( !_localWorkDB ){
        NSString *sqlCreateTable = [NSString stringWithFormat:@"create table if not exists %@ (ID Integer PRIMARY KEY AUTOINCREMENT, name text, category text, price text, saleCount text, buyUrl text, desc text, audioPath text, musicName text, originImgUrls text, midImgUrls text, clearImgUrls text, videoLength text, videoPath text, videoCover text, workType text)",tableRecentQueryTrainLate];
        _localWorkDB =[self createTableWithSql:sqlCreateTable
                                             dataBaseName:@"local_work.db"
                                                 dateBase:_localWorkDB]; //_recentQueryStationSaleTimeDB];
    }
    return _localWorkDB;
}

#pragma mark - Private

- (NSString *)getDbPathWithName:(NSString *)name{
    return [self getDbPathWithName:name isCommonDir:NO dataBaseName:@"dataBase"];
}

- (NSString *)getImgCacheDir{
    return [self getDbPathWithName:@"imgCache" isCommonDir:YES dataBaseName:nil];
}

/**
 获取数据库的目录
 
 @param name 数据库的名字
 @param iscommon 是否放在公用目录下。是则放在所用用户公用目录，否则放在当前用户目录下。
 @return 数据库目录
 */
-(NSString*)getDbPathWithName:(NSString*)name isCommonDir:(BOOL)iscommon dataBaseName:(NSString*)dbName{
    if( name == nil || name.length == 0 )  return nil;
    
    NSString *pathPrefix  = _userModel.userId;
    if( pathPrefix==nil || pathPrefix.length ==0 ){
        pathPrefix = @"defaultUserName";
    }
    if( iscommon ){
        pathPrefix = @"AllUserCommon";
    }
    
    NSString *dataBaseName = dbName;
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dir = [NSString stringWithFormat:@"%@/%@/",docPath,pathPrefix];
    if( dataBaseName ){
        dir = [dir stringByAppendingString:dataBaseName];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:dir] == NO ){
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbPath = [dir stringByAppendingPathComponent:name];
    return dbPath;
}

-(sqlite3*)openDataBase:(sqlite3*)dbInfo path:(NSString*)path sql:(NSString*)sqlStr{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL find = [fm fileExistsAtPath:path];
    //如果数据库存在，则用sqlite3_open直接打开
    if( find ){
        //打开数据库
        if( sqlite3_open([path UTF8String], &dbInfo) != SQLITE_OK ){
            sqlite3_close(dbInfo);
            return nil;
        }
        return dbInfo;
    }
    
    //如果发现数据库不存在则利用sqlite3_open创建数据库
    int ret = sqlite3_open([path UTF8String], &dbInfo);
    
    if( ret == SQLITE_OK ){
        //创建新表
        if([self createTable:dbInfo sql:[sqlStr UTF8String]]){
            return dbInfo;
        }
    }else{
        //如果创建并打开数据库失败则关闭数据库
        sqlite3_close(dbInfo);
        return nil;
    }
    return nil;
}

//创建表
-(BOOL)createTable:(sqlite3*)db sql:(const char*)sql{
    sqlite3_stmt *statement;
    //sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去，使用该接口访问数据库是当前比较好的一种办法
    NSInteger sqlRet = sqlite3_prepare_v2(db, sql, -1, &statement, nil);
    //如果SQL语句解析出错的话，程序返回
    if( sqlRet != SQLITE_OK )
        return NO;
    //执行SQL语句
    int success = sqlite3_step(statement);
    //释放sqlite3_stmt
    sqlite3_finalize(statement);
    //执行SQL语句失败
    if( success != SQLITE_DONE ){
        return NO;
    }
    return YES;
}

/**
 *  删除ID小于MaxId 的数据，若maxId <=0 则删除所有数据
 *
 *  @param maxId 待删除的数据ID的最大值
 *  @param table 待删除的数据的表
 *  @param db    待删除的数据的数据库文件
 *
 *  @return 成功YES 失败NO
 */
- (BOOL)deleteDataWithMaxId:(NSInteger)maxId table:(NSString*)table dataBase:(sqlite3*)db{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ID<%ld",table,maxId];
    if( maxId <=0 ){
        sql = [NSString stringWithFormat:@"DELETE FROM %@",table];
    }
    sqlite3_stmt *statement ;
    int success = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL);
    if( success != SQLITE_OK ){
        return NO;
    }
    
    //执行
    char *errMsg = nil;
    success = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errMsg);
    //释放statement
    sqlite3_finalize(statement);
    
    return (success == SQLITE_OK);
}

/**
 *  创建数据库文件及表
 *
 *  @param sql    创建表语句
 *  @param dbName 数据库名字
 *  @param db     数据库文件对象
 *
 *  @return 表对应的数据库对象
 */
- (sqlite3*)createTableWithSql:(NSString*)sql dataBaseName:(NSString*)dbName dateBase:(sqlite3*)db{
    NSString *dbPath = [self getDbPathWithName:dbName];
    
    return  [self openDataBase:db path:dbPath sql:sql];
}

- (BOOL)isExistInDataBase:(sqlite3*)db tableName:(NSString*)tableName segmentName:(NSString*)segementName value:(NSString*)value{
    return [self isExistInDataBase:db tableName:tableName segmentName:segementName value:value needDelete:NO];
}

/*
 * 查询某个数据是否存在数据库。存在则直接删除并返回NO
 * @param db 要查询的数据库
 * @param tableName 要查询的表的名字
 * @param segementName 字段的名字。要查询的值对应的字段
 * @param value 要查询的数据
 *
 * @return 存在 返回YES ，不存在No
 */
- (BOOL)isExistInDataBase:(sqlite3*)db tableName:(NSString*)tableName segmentName:(NSString*)segementName value:(NSString*)value needDelete:(BOOL)needDelete{
    
    if( db == nil || tableName ==nil || segementName.length ==0 || value.length == 0 ){
        //        不插入
        return YES;
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' order by id DESC",tableName,segementName,value];
    sqlite3_stmt *statement;
    const char *err;
    
    BOOL isExist = NO;
    int ret = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, &err);
    if( ret == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW ) {
            int iditify = sqlite3_column_int(statement, 0);
            
            if( needDelete ){
                //若存在则删除
                BOOL delRet = [self deleteDataWithID:iditify dataBase:db table:tableName];
                if( !delRet ){
                    isExist = YES;
                }
            }else{
                isExist = YES;
                break;
            }
        }
    }
    
    sqlite3_finalize(statement);
    
    return isExist;
}

- (BOOL)deleteValuesOfExistInDataBase:(sqlite3*)db tableName:(NSString*)tableName segmentNames:(NSArray<NSString*>*)segementNames values:(NSArray<NSString*>*)values{
    
    if( db == nil || tableName ==nil || segementNames.count ==0 || values.count == 0 || segementNames.count != values.count ){
        //删除失败
        return NO;
    }
    
    NSString *segsAndValuesStr = nil;
    for( NSUInteger i=0; i<segementNames.count; i++ ){
        NSString *segName = segementNames[i];
        NSString *value= values[i];
        if( [NSString stringWithObj:segName] ){
            if( segsAndValuesStr == nil ){
                segsAndValuesStr = [NSString stringWithFormat:@"%@='%@'",segName,value];
            }
            else{
                segsAndValuesStr = [NSString stringWithFormat:@"%@ and %@='%@'",segsAndValuesStr,segName,value];
            }
        }
    }
    
    if( segsAndValuesStr == nil )
        return NO;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ order by id DESC",tableName,segsAndValuesStr];
    sqlite3_stmt *statement;
    const char *err;
    
    BOOL isExist = NO;
    int ret = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, &err);
    if( ret == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW ) {
            int iditify = sqlite3_column_int(statement, 0);
            //若存在则删除
            BOOL delRet = [self deleteDataWithID:iditify dataBase:db table:tableName];
            if( !delRet ){
                isExist = YES;
            }
        }
    }
    
    sqlite3_finalize(statement);
    
    return isExist;
}

- (BOOL)deleteDataWithID:(int)dataID dataBase:(sqlite3*)db table:(NSString*)table{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ID=%d",table,dataID];
    sqlite3_stmt *statement ;
    int success = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL);
    if( success != SQLITE_OK ){
        //释放statement
        sqlite3_finalize(statement);
        return NO;
    }
    
    //执行
    char *errMsg = nil;
    success = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errMsg);
    //释放statement
    sqlite3_finalize(statement);
    
    return (success == SQLITE_OK);
}

- (void)sqliteBindText:(NSString*)text statement:(sqlite3_stmt *)statement index:(int)index{
    NSString *textStr = [NSString stringWithObj:text];
    if( [textStr isKindOfClass:[NSString class]] ){
        sqlite3_bind_text(statement, index, [textStr UTF8String], -1, SQLITE_TRANSIENT);
    }
}

- (NSString*)sqliteColumnTextWithStatment:(sqlite3_stmt*)statement index:(int)index{
    char *name = (char*)sqlite3_column_text(statement, index);
    if( name != NULL ){
        return [NSString stringWithUTF8String:name];
    }
    return nil;
}


@end
