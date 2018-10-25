




//
//  WMZSQliteManage.m
//  WMZSQLite
//
//  Created by wmz on 2018/9/29.
//  Copyright © 2018年 wmz. All rights reserved.
//

#import "WMZSQliteManage.h"
#import <objc/runtime.h>
#import "FMDB.h"
#import <UIKit/UIKit.h>

/*
 * 数据库插入的模型必须相同！！！
 */

typedef enum : NSUInteger{
    SQLStringTypeCreate,         //创建
    SQLStringTypeInsert,         //增加
    SQLStringTypeUpdate,         //更新
    SQLStringTypeDeleteAll,      //删除全部
    SQLStringTypeDeleteTable,    //删除表
    SQLStringTypeSelectAll,      //查找全部
    SQLStringTypeSelectLast,     //查找最后一条
    SQLStringTypeSelectFirst,    //查找第一条
    SQLStringTypeSelectLastFew,  //查找最后几条
    SQLStringTypeSelectFirstFew, //查找前几条
    SQLStringTypeSelectOther     //查找符合条件的
}SQLStringType;

#define AUTOINCREMENT_FIELD @"wmzID"

@interface WMZSQliteManage()

@property(nonatomic,strong)FMDatabaseQueue  *baseQuene;

@property(nonatomic,strong)NSString *dbPath;

@property(nonatomic,strong)NSString *dbTableName;

@end

@implementation WMZSQliteManage

static WMZSQliteManage *_instance;
+ (instancetype)sharedDBManager
{
    
    static dispatch_once_t onceToken_FileManager;
    
    dispatch_once(&onceToken_FileManager, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

//插入数组数据
- (BOOL)insertModelArr:(NSArray*)modelArr toFile:(NSString*)fileName{
    BOOL result = false;

    NSMutableArray *numArr = [NSMutableArray new];
    for (int i = 0; i<modelArr.count; i++) {
         result =  [self insertModel:modelArr[i] toFile:fileName];
        if (!result) {
            [numArr addObject:@(i)];
        }
    }
    if (numArr.count>0) {
        for (NSNumber *num in numArr) {
            NSLog(@"第%@个插入不成功",num);
        }
    }else{
        NSLog(@"全部插入成功");
    }
    return result;
}

//插入数据
- (BOOL)insertModel:(id)model toFile:(NSString*)fileName{
    [self getFilePathWithFileName:fileName];
    BOOL __block result;
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        //表存在
        if ([db tableExists:self->_dbTableName]) {
            result =  [db executeUpdate:[self connectionSQLStringWithType:SQLStringTypeInsert withModel:model withCount:0]];
            if (result) {
                NSLog(@"数据插入成功");
            }else{
                NSLog(@"数据插入失败");
            }

        }else{
            result =  [db executeUpdate:[self connectionSQLStringWithType:SQLStringTypeCreate withModel:model withCount:0]];
            
            if (result) {
               result =  [db executeUpdate:[self connectionSQLStringWithType:SQLStringTypeInsert withModel:model withCount:0]];
                if (result) {
                    NSLog(@"表创建成功，输入插入成功");
                }else{
                    NSLog(@"表创建成功，输入插入失败");
                }
            }else{
                NSLog(@"表创建失败");
            }
        }
    }];
    return result;
}

//查询所有数据
- (NSArray*)selectAllDataWithModelClass:(Class)kclass WithFile:(NSString*)fileName{
    NSMutableArray *returnArr = [NSMutableArray new];
    [self getFilePathWithFileName:fileName];
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        //表存在
        if ([db tableExists:self->_dbTableName]) {
           FMResultSet *set =  [db executeQuery:[self connectionSQLStringWithType:SQLStringTypeSelectAll withModel:nil withCount:0]];
            while ([set next]) {
                 NSString __block *jsonString = @"";
                [[set resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
//                        NSLog(@"%@",obj);
                         jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                id objc = [[[kclass class] alloc]init];
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                [returnArr addObject:objc];

            }
            
        }else{
            NSLog(@"不存在表格");
            return;
        }
    }];
    return [NSArray arrayWithArray:returnArr];
}

//删除所有数据
- (BOOL)deleteFMDBWithFile:(NSString*)fileName{
    [self getFilePathWithFileName:fileName];
    BOOL __block result;
    
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db tableExists:self->_dbTableName]) {
            result = [db executeUpdate:[self connectionSQLStringWithType:SQLStringTypeDeleteAll withModel:nil withCount:0]];
            if (result) {
                NSLog(@"删除成功");
            }else{
                NSLog(@"删除失败");
            }
        }else{
            NSLog(@"表格不存在");
            result = NO;
        }
      
    }];
    return result;
    //删除整个本地文件
//    if ([[NSFileManager defaultManager] removeItemAtPath:_dbPath error:nil]) {
//        NSLog(@"删除成功");
//        return YES;
//    } else {
//        NSLog(@"删除失败");
//        return NO;
//    }
}

//删除整个表
- (BOOL)deleteTableWithFile:(NSString *)fileName{
    [self getFilePathWithFileName:fileName];
    BOOL __block result;
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db tableExists:self->_dbTableName]) {
            result = [db executeUpdate:[self connectionSQLStringWithType:SQLStringTypeDeleteTable withModel:nil withCount:0]];
            if (result) {
                NSLog(@"删除表成功");
            }else{
                NSLog(@"删除表失败");
            }
        }else{
            NSLog(@"表格不存在");
            result = NO;
        }
        
    }];
    return result;
}

//获取最后一条数据
- (id)getLastDataWithModelClass:(Class)kclass WithFile:(NSString *)fileName{
    __block id returnID ;
    [self getFilePathWithFileName:fileName];
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        //表存在
        if ([db tableExists:self->_dbTableName]) {
            FMResultSet *set =  [db executeQuery:[self connectionSQLStringWithType:SQLStringTypeSelectLast withModel:nil withCount:0]];
            while ([set next]) {
                NSString __block *jsonString = @"";
                [[set resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
                        //                        NSLog(@"%@",obj);
                        jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                id objc = [[[kclass class] alloc]init];
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                returnID = objc;
                return;
                
            }
            
        }else{
            NSLog(@"不存在表格");
            return ;
        }
    }];
    return returnID;
}

//获取第一条数据
- (id)getFirstDataWithModelClass:(Class)kclass WithFile:(NSString *)fileName{
    __block id returnID ;
    [self getFilePathWithFileName:fileName];
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        //表存在
        if ([db tableExists:self->_dbTableName]) {
            FMResultSet *set =  [db executeQuery:[self connectionSQLStringWithType:SQLStringTypeSelectFirst withModel:nil withCount:0]];
            while ([set next]) {
                NSString __block *jsonString = @"";
                [[set resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
                        //                        NSLog(@"%@",obj);
                        jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                id objc = [[[kclass class] alloc]init];
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                returnID = objc;
                return;
                
            }
            
        }else{
            NSLog(@"不存在表格");
            return ;
        }
    }];
    return returnID;
}

//获取最后几条数据
- (NSArray*)getLastFewDataWithModelClass:(Class)kclass WithCount:(NSInteger)count WithFile:(NSString *)fileName{
    NSMutableArray *returnArr = [NSMutableArray new];
    [self getFilePathWithFileName:fileName];
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        //表存在
        if ([db tableExists:self->_dbTableName]) {
            FMResultSet *set =  [db executeQuery:[self connectionSQLStringWithType:SQLStringTypeSelectLastFew withModel:nil withCount:count]];
            while ([set next]) {
                NSString __block *jsonString = @"";
                [[set resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
                        //                        NSLog(@"%@",obj);
                        jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                id objc = [[[kclass class] alloc]init];
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                [returnArr addObject:objc];
                
            }
            
        }else{
            NSLog(@"不存在表格");
            return;
        }
    }];
    return [NSArray arrayWithArray:returnArr];
}

//获取前几条数据
- (NSArray*)getFirsFewtDataWithModelClass:(Class)kclass WithCount:(NSInteger)count WithFile:(NSString *)fileName{
    NSMutableArray *returnArr = [NSMutableArray new];
    [self getFilePathWithFileName:fileName];
    [self.baseQuene inDatabase:^(FMDatabase * _Nonnull db) {
        //表存在
        if ([db tableExists:self->_dbTableName]) {
            FMResultSet *set =  [db executeQuery:[self connectionSQLStringWithType:SQLStringTypeSelectFirstFew withModel:nil withCount:count]];
            while ([set next]) {
                NSString __block *jsonString = @"";
                [[set resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
                        //                        NSLog(@"%@",obj);
                        jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                id objc = [[[kclass class] alloc]init];
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                [returnArr addObject:objc];
                
            }
            
        }else{
            NSLog(@"不存在表格");
            return;
        }
    }];
    return [NSArray arrayWithArray:returnArr];
}

//根据类型创建SQL语句
- (NSString*)connectionSQLStringWithType:(SQLStringType)type withModel:(id)model withCount:(NSInteger)count{
    NSString *returnSQLString = @"";
    switch (type) {
        case SQLStringTypeCreate:
        {
            returnSQLString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,JSON TEXT)",_dbTableName,AUTOINCREMENT_FIELD];
        }
        break;
        case SQLStringTypeInsert:
        {
            NSString *jsonStr = @"";
            //字典转json
            jsonStr = [self dictionaryToJson:[self getProperty:model]];
            returnSQLString = [NSString stringWithFormat:@"INSERT INTO %@ (JSON) VALUES ('%@')",_dbTableName,jsonStr];
            
        }
        break;
        case SQLStringTypeUpdate:
        {
            //需要传入需要修改的数据 以及条件
//            UPDATE _dbTableName
//            SET name = 'MM'
//            WHERE age = 10;
        }
            break;
        case SQLStringTypeDeleteAll:
        {
            returnSQLString = [NSString stringWithFormat:@"DELETE  FROM %@",_dbTableName];
        }
            break;
        case SQLStringTypeSelectAll:
        {
            returnSQLString = [NSString stringWithFormat:@"SELECT * FROM %@",_dbTableName];
        }
            break;
        case SQLStringTypeSelectLast:
        {
            returnSQLString =  [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC LIMIT 1",_dbTableName,AUTOINCREMENT_FIELD];

        }
            break;
        case SQLStringTypeSelectFirst:
        {
            returnSQLString =  [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC LIMIT 1",_dbTableName,AUTOINCREMENT_FIELD];
            
        }
            break;
        case SQLStringTypeSelectLastFew:
        {
            returnSQLString =  [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC LIMIT %ld",_dbTableName,AUTOINCREMENT_FIELD,count];
            
        }
            break;
        case SQLStringTypeSelectFirstFew:
        {
            returnSQLString =  [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC LIMIT %ld",_dbTableName,AUTOINCREMENT_FIELD,count];
            
        }
            break;
        case SQLStringTypeSelectOther:
        {
            //修改数据库语句 方法一样
        }
            break;
        case SQLStringTypeDeleteTable:{
             /*删除表*/
            returnSQLString = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",_dbTableName];
        }
            break;
        default:
            break;
    }
    return returnSQLString;
}

//获取模型中的属性类型和数据
- (NSMutableDictionary*)getProperty:(id)model{
    
    unsigned int count;
    
    NSMutableArray *nameArr = [NSMutableArray new];
    NSMutableArray *typeArr = [NSMutableArray new];
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary new];
    
    
    Ivar *ivars = class_copyIvarList([model class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        if (ivar_getName(ivar)) {
            [nameArr addObject: [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""]];
        }
        if (ivar_getTypeEncoding(ivar)) {
            [typeArr addObject:[NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)]];
        }
        
    }
    
    for (int i = 0; i<nameArr.count; i++) {
        NSString *name = nameArr[i];
        NSString *type = typeArr[i];
        id typeValue = [model valueForKey:name]?:@"";
        //id类型
        if ([type containsString:@"@"]) {
            if ([type isEqualToString:@"@"]) {
                typeValue = [self setIDVariableToString:[model valueForKey:name]];
            }else if([type containsString:@"NSArray"]||[type containsString:@"NSMutableArray"]||[type containsString:@"NSDictionary"]||[type containsString:@"NSMutableDictionary"]){
                typeValue = [[NSJSONSerialization dataWithJSONObject:[model valueForKey:name] options:NSJSONWritingPrettyPrinted error:nil] base64EncodedStringWithOptions:0];
            }else if ([type containsString:@"NSString"]) {
                
            }else{
                if (typeValue) {
                    typeValue =  [self getProperty:typeValue];
                }
            }
        }
        
        [jsonDic setObject:typeValue forKey:name];
    }
    free(ivars);
    return jsonDic;
}

// 通过字典获取模型数据
- (id)getModel:(Class)kclass withDataDic:(NSDictionary *)kDic{
    
    id objc = [[[kclass class] alloc]init];
    unsigned int count;
    NSString *kvarsKey = @"";   //获取成员变量的名字
    NSString *kvarsType = @"";  //成员变量类型
    Ivar *ivars = class_copyIvarList([kclass class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
       kvarsKey =  [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
       kvarsType =  [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
       id ivarValue = [kDic objectForKey:kvarsKey];
        if ([kvarsType containsString:@"@"]) {
            if ([kvarsType isEqualToString:@"@"]) {
                ivarValue = [self getIDVariableValueTypesWithString:ivarValue];
                
            }else if([kvarsType containsString:@"NSArray"]||[kvarsType containsString:@"NSMutableArray"]||[kvarsType containsString:@"NSDictionary"]||[kvarsType containsString:@"NSMutableDictionary"]){
                ivarValue = [NSJSONSerialization JSONObjectWithData:[[NSData alloc]initWithBase64EncodedString:[kDic objectForKey:kvarsKey] options:0] options:NSJSONReadingMutableLeaves error:nil];
                
            }else if ([kvarsType containsString:@"NSString"]) {
                
                ivarValue = [NSString stringWithFormat:@"%@",[kDic objectForKey:kvarsKey]];
                
            }else if ([kvarsType isEqualToString:@"c"]){
                ivarValue = [NSNumber numberWithChar:[ivarValue intValue]];
            }
            //i - int
            else if ([kvarsType isEqualToString:@"i"]){
                ivarValue = [NSNumber numberWithInt:[ivarValue intValue]];
            }
            //s - short
            else if ([kvarsType isEqualToString:@"s"]){
                ivarValue = [NSNumber numberWithShort:[ivarValue intValue]];
            }
            //l - long
            else if ([kvarsType isEqualToString:@"l"]){
                ivarValue = [NSNumber numberWithLong:[ivarValue intValue]];
            }
            //q - long long
            else if ([kvarsType isEqualToString:@"q"]){
                ivarValue = [NSNumber numberWithLongLong:[ivarValue intValue]];
            }
            //C - unsigned char
            else if ([kvarsType isEqualToString:@"C"]){
                ivarValue = [NSNumber numberWithUnsignedChar:[ivarValue intValue]];
            }
            //I - unsigned int
            else if ([kvarsType isEqualToString:@"I"]){
                ivarValue = [NSNumber numberWithUnsignedInt:[ivarValue intValue]];
            }
            //S - unsigned short
            else if ([kvarsType isEqualToString:@"S"]){
                ivarValue = [NSNumber numberWithUnsignedShort:[ivarValue intValue]];
            }
            //L - unsigned long
            else if ([kvarsType isEqualToString:@"L"]){
                ivarValue = [NSNumber numberWithUnsignedLong:[ivarValue intValue]];
            }
            //Q - unsigned long long
            else if ([kvarsType isEqualToString:@"Q"]){
                ivarValue = [NSNumber numberWithUnsignedLongLong:[ivarValue intValue]];
            }
            //f - float
            else if ([kvarsType isEqualToString:@"f"]){
                ivarValue = [NSNumber numberWithFloat:[ivarValue floatValue]];
            }
            //d - double
            else if ([kvarsType isEqualToString:@"d"]){
                ivarValue = [NSNumber numberWithDouble:[ivarValue doubleValue]];
            }
            //B - bool or a C99 _Bool
            else if ([kvarsType isEqualToString:@"B"]) {
                if ([ivarValue isEqualToString:@"1"]) {
                    ivarValue = [NSNumber numberWithBool:YES];
                } else {
                    ivarValue = [NSNumber numberWithBool:NO];
                }
            }
            
            else{
                NSString *type = @"";
                if (kvarsType.length>4) {
                    type = [kvarsType substringWithRange:NSMakeRange(2, kvarsType.length-3)];
                }
                if ([ivarValue isKindOfClass:[NSDictionary class]]||[ivarValue isKindOfClass:[NSMutableDictionary class]]) {
                    if (ivarValue&&[[ivarValue allKeys] count]>0) {
                        ivarValue =  [self getModel:NSClassFromString(type) withDataDic:ivarValue];
                        
                    }
                }else if ([ivarValue isKindOfClass:[NSArray class]]||[ivarValue isKindOfClass:[NSMutableArray class]]){
                    if ([ivarValue count]>0) {
                        ivarValue =  [self getModel:NSClassFromString(type) withDataDic:ivarValue];
                        
                    }
                }else if ([ivarValue isKindOfClass:[NSString class]]){
                    if (ivarValue) {
                        ivarValue =  [self getModel:NSClassFromString(type) withDataDic:ivarValue];
                        
                    }
                }
                
            }
        }else{
            ivarValue = [kDic objectForKey:kvarsKey];
        }
        if (ivarValue) {
            [objc setValue:ivarValue forKey:kvarsKey];
        }
        
    }
    
    return objc;
}


//获取文件路径
- (void)getFilePathWithFileName:(NSString *)fileName
{
    NSAssert(fileName || ![fileName isEqualToString:@""], @"数据库文件名不可为空!");
    _dbTableName = [@"WMZ" stringByAppendingString:fileName];
    _dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",_dbTableName]];
    if (!_baseQuene) {
         _baseQuene = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    }
}

//字典转字符串
- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//字符串转字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//根据id变量类型转化为对应string以供存储
- (NSString *)setIDVariableToString:(id)varialeValue
{
    //NSString类型
    if ([varialeValue isKindOfClass:[NSString class]]) {
        return varialeValue?[NSString stringWithFormat:@"%@:NSString",varialeValue]:@"";
    }
    //BOOL类型
    else if ([[NSString stringWithFormat:@"%@",[varialeValue class]] isEqualToString:@"__NSCFBoolean"]) {
        return varialeValue?[NSString stringWithFormat:@"%@:NSNumberBOOL",varialeValue]:@"";
    }
    //NSSNumber类型
    else if ([varialeValue isKindOfClass:[NSNumber class]]) {
        
        NSString *memberValueType = @":NSNumber";
        
        if (strcmp([varialeValue objCType], @encode(char)) == 0 ||
            strcmp([varialeValue objCType], @encode(unsigned char)) == 0) {
            memberValueType = @":NSNumberChar";
        } else if (strcmp([varialeValue objCType], @encode(short)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned short)) == 0) {
            memberValueType = @":NSNumberShort";
        } else if (strcmp([varialeValue objCType], @encode(int)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned int)) == 0) {
            memberValueType = @":NSNumberInt";
        } else if (strcmp([varialeValue objCType], @encode(long)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned long)) == 0) {
            memberValueType = @":NSNumberLong";
        } else if (strcmp([varialeValue objCType], @encode(long long)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned long long)) == 0) {
            memberValueType = @":NSNumberLongLong";
        } else if (strcmp([varialeValue objCType], @encode(float)) == 0) {
            memberValueType = @":NSNumberFloat";
        } else if (strcmp([varialeValue objCType], @encode(double)) == 0) {
            memberValueType = @":NSNumberDouble";
        } else if (strcmp([varialeValue objCType], @encode(NSInteger)) == 0) {
            memberValueType = @":NSNumberNSInteger";
        } else if (strcmp([varialeValue objCType], @encode(NSUInteger)) == 0) {
            memberValueType = @":NSNumberNSUInteger";
        }
        
        return varialeValue?[NSString stringWithFormat:@"%@%@",varialeValue,memberValueType]:@"";
    }
    //UIView类型
    else if ([[varialeValue class] isSubclassOfClass:[UIView class]] || [[varialeValue class] isKindOfClass:[UIView class]]) {
        return varialeValue?[NSString stringWithFormat:@"%@:UIView",varialeValue]:@"";
    }
    
    return varialeValue?[NSString stringWithFormat:@"%@:id",varialeValue]:@"";
}

//根据存储的信息转为对应的变量类型
- (id)getIDVariableValueTypesWithString:(NSString *)string
{
    NSString *idValueType = [[string componentsSeparatedByString:@":"] lastObject];
    NSString *idValue = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@",idValueType] withString:@""];
    
    if ([idValueType isEqualToString:@"NSNumber"]) {
        return [NSNumber numberWithInteger:[idValue integerValue]];
    } else if ([idValueType isEqualToString:@"NSNumberChar"]) {
        return [NSNumber numberWithChar:[idValue intValue]];
    } else if ([idValueType isEqualToString:@"NSNumberFloat"]) {
        return [NSNumber numberWithFloat:[idValue floatValue]];
    } else if ([idValueType isEqualToString:@"NSNumberDouble"]) {
        return [NSNumber numberWithDouble:[idValue doubleValue]];
    } else if ([idValueType isEqualToString:@"NSNumberShort"]) {
        return [NSNumber numberWithShort:[idValue intValue]];
    } else if ([idValueType isEqualToString:@"NSNumberInt"]) {
        return [NSNumber numberWithInt:[idValue doubleValue]];
    } else if ([idValueType isEqualToString:@"NSNumberLong"]) {
        return [NSNumber numberWithLong:[idValue floatValue]];
    } else if ([idValueType isEqualToString:@"NSNumberLongLong"]) {
        return [NSNumber numberWithLongLong:[idValue longLongValue]];
    } else if ([idValueType isEqualToString:@"NSNumberNSInteger"]) {
        return [NSNumber numberWithInteger:[idValue integerValue]];
    } else if ([idValueType isEqualToString:@"NSNumberNSUInteger"]) {
        return [NSNumber numberWithUnsignedInteger:[idValue integerValue]];
    } else if ([idValueType isEqualToString:@"NSNumberBOOL"]) {
        return [NSNumber numberWithBool:[idValue boolValue]];
    } else if ([idValueType isEqualToString:@"UIView"]) {
        return NSClassFromString(idValue);
    } else if ([idValueType isEqualToString:@"NSString"]) {
        return idValue;
    }
    return @"";
}

@end
