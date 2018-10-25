//
//  TestSecondModel.h
//  WMZSQLite
//
//  Created by wmz on 2018/9/30.
//  Copyright © 2018年 wmz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestSecondModel : NSObject
@property(nonatomic,strong)NSString *address;

@property(nonatomic,assign)NSInteger birthday;

@property(nonatomic,assign)BOOL turn;

@property(nonatomic,strong)NSArray *arrSecond;

@property(nonatomic,strong)NSDictionary *dicSecond;
@end

NS_ASSUME_NONNULL_END
