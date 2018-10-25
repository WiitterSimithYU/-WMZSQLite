//
//  WMZSQliteManage.h
//  WMZSQLite
//
//  Created by wmz on 2018/9/29.
//  Copyright © 2018年 wmz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMZSQliteManage : NSObject

/*
 * 单例
 */
+ (instancetype)sharedDBManager;

/*
 * 插入数据
 *
 * @param  model 插入的模型数据
 * @param  fileName 表名
 *
 * @return 是否插入成功
 */
- (BOOL)insertModel:(id)model toFile:(NSString*)fileName;

/*
 * 插入数组数据
 *
 * @param  modelArr 插入的模型数组数据
 * @param  fileName 表名
 *
 * @return 是否插入成功
 */
- (BOOL)insertModelArr:(NSArray*)modelArr toFile:(NSString*)fileName;

/*
 * 查询表的所有数据
 *
 * @param  kclass 查询的数据对应的模型
 * @param  fileName 表名
 *
 * @return 查询的数据数组
 */
- (NSArray*)selectAllDataWithModelClass:(Class)kclass WithFile:(NSString*)fileName;

/*
 * 删除表中的数据
 *
 * @param  fileName 表名
 *
 * @return 是否删除成功
 */
- (BOOL)deleteFMDBWithFile:(NSString*)fileName;

/*
 * 删除整个表
 *
 * @param  fileName 表名
 *
 * @return 是否删除成功
 */
- (BOOL)deleteTableWithFile:(NSString*)fileName;

/*
 * 查询表的最后一条数据
 *
 * @param  kclass 查询的数据对应的模型
 * @param  fileName 表名
 *
 * @return 查询的数据
 */
- (id)getLastDataWithModelClass:(Class)kclass WithFile:(NSString*)fileName;

/*
 * 查询表的第一条数据
 *
 * @param  kclass 查询的数据对应的模型
 * @param  fileName 表名
 *
 * @return 查询的数据
 */
- (id)getFirstDataWithModelClass:(Class)kclass WithFile:(NSString*)fileName;

/*
 * 查询表的最后几条数据
 *
 * @param  kclass 查询的数据对应的模型
 * @param  count 多少条
 * @param  fileName 表名
 *
 * @return 查询的数据
 */
- (NSArray*)getLastFewDataWithModelClass:(Class)kclass WithCount:(NSInteger)count WithFile:(NSString*)fileName;

/*
 * 查询表的前几条数据
 *
 * @param  kclass 查询的数据对应的模型
 * @param  count 多少条
 * @param  fileName 表名
 *
 * @return 查询的数据
 */
- (NSArray*)getFirsFewtDataWithModelClass:(Class)kclass WithCount:(NSInteger)count WithFile:(NSString*)fileName;

@end

