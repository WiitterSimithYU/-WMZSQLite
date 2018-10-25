//
//  ViewController.m
//  WMZSQLite
//
//  Created by wmz on 2018/9/29.
//  Copyright © 2018年 wmz. All rights reserved.
//


/*
 *只支持存储任何复杂的自定义模型（或者包含模型的数组）  其他简单的基本类型如NSString NSNunber NSDictionary等不支持建议用userDefaultt储存即可
 */

#import "ViewController.h"
#import "TestModel.h"
#import "WMZSQliteManage.h"
#define fileName @"testModel1"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    // Do any additional setup after loading the view, typically from a nib.
    [self UI];
   
   
}

- (void)UI{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [btn setTitle:@"获取全部" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn sizeToFit];
    // button target
    [btn addTarget:self action:@selector(getAll:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(50, 50, 100, 100);
    [self.view addSubview:btn];
    
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [btn1 setTitle:@"删除全部" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 sizeToFit];
    // button target
    [btn1 addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
    btn1.frame = CGRectMake(200, 50, 100, 100);
    [self.view addSubview:btn1];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [btn2 setTitle:@"获取最后一条" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 sizeToFit];
    // button target
    [btn2 addTarget:self action:@selector(getLast:) forControlEvents:UIControlEventTouchUpInside];
    btn2.frame = CGRectMake(50, 200, 150, 100);
    [self.view addSubview:btn2];
    
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [btn3 setTitle:@"添加" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn3 sizeToFit];
    // button target
    [btn3 addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    btn3.frame = CGRectMake(200, 200, 150, 100);
    [self.view addSubview:btn3];
}

//获得最后几条数据
- (void)getLast:(UIButton*)btn{
    id result =  [[WMZSQliteManage sharedDBManager] getLastFewDataWithModelClass:[TestModel class] WithCount:1 WithFile:fileName];

    for (TestModel *model in result) {
        NSLog(@"%@",model.name);
    }
}

//获得所有数据
- (void)getAll:(UIButton*)btn{
   NSArray *arr =   [[WMZSQliteManage sharedDBManager] selectAllDataWithModelClass:[TestModel class] WithFile:fileName];
    NSLog(@"返回 %@",arr);
    for (TestModel *model in arr) {
        NSLog(@"%@",model.name);
        
    }
    
}

//删除全部
- (void)deleteAll:(UIButton*)btn{
    [[WMZSQliteManage sharedDBManager] deleteTableWithFile:fileName];
}

//添加数据
- (void)add:(UIButton*)btn{
    [[WMZSQliteManage sharedDBManager] insertModelArr:[self getModel] toFile:fileName];
}


//创建数据模型
- (id)getModel{
    NSMutableArray *arr = [NSMutableArray new];
    for (int i = 0; i<5; i++) {
        TestModel *model = [TestModel new];
        int y =100 +  (arc4random() % 101);
        model.name = [NSString stringWithFormat:@"%d位wmz",y];
        model.age = 25;
        model.hix = YES;
        model.arr = @[@"1",@"2"];
        model.dic = @{@"1":@"1key",@"2":@"2key"};
        model.ID = @"wmzID";
        
        TestSecondModel *model1 = [TestSecondModel new];
        model1.address = @"wxx";
        model1.birthday = 23;
        model1.turn = NO;
        model1.arrSecond = @[@"3",@"4"];
        model1.dicSecond = @{@"3":@"3key",@"4":@"4key"};
        
        
        TestModel *model3 = [TestModel new];
        model3.name = @"wmz1";
        model3.age = 252;
        model3.hix = YES;
        model3.arr = @[@"11",@"22"];
        model3.dic = @{@"11":@"11key",@"22":@"22key"};
        model3.ID = @"wmz11ID";
        
        TestSecondModel *model4 = [TestSecondModel new];
        model4.address = @"wxx";
        model4.birthday = 23;
        model4.turn = NO;
        model4.arrSecond = @[@"3",@"4"];
        model4.dicSecond = @{@"3":@"3key",@"4":@"4key"};
        
        TestModel *model2 = [TestModel new];
        model2.name = @"wmz1";
        model2.age = 252;
        model2.hix = YES;
        model2.arr = @[@"11",@"22"];
        model2.dic = @{@"11":@"11key",@"22":@"22key"};
        model2.ID = @"wmz11ID";
        model2.secondModel = model4;
        model2.thirdModel = model3;
        
        model.secondModel = model1;
        model.thirdModel = model2;
        [arr addObject:model];
    }
    return arr;
}

@end
