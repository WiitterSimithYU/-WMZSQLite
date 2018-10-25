//
//  TestModel.h
//  WMZSQLite
//
//  Created by wmz on 2018/9/29.
//  Copyright © 2018年 wmz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestSecondModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface TestModel : NSObject

@property(nonatomic,strong)id ID;

@property(nonatomic,strong)NSString *name;

@property(nonatomic,assign)NSInteger age;

@property(nonatomic,assign)BOOL hix;

@property(nonatomic,strong)NSArray *arr;

@property(nonatomic,strong)NSDictionary *dic;

@property(nonatomic,strong)TestSecondModel *secondModel;

@property(nonatomic,strong)TestModel *thirdModel;

@end
NS_ASSUME_NONNULL_END



