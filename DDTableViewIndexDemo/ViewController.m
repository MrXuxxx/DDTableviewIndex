//
//  ViewController.m
//  DDTableViewIndexDemo
//
//  Created by xudong on 2019/1/30.
//  Copyright © 2019 dong. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+DDCoustomIndexView.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *testTableView;
@property (strong, nonatomic)NSArray *dataArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataArr = @[@[@"a",@"a",@"a",@"a"],@[@"b",@"b",@"b",@"b"],@[@"c",@"c",@"c",@"c"],@[@"d",@"d",@"d"],@[@"e",@"e",@"e",@"e"],@[@"f",@"f",@"f",@"f"],@[@"g",@"g",@"g"],@[@"h",@"h"],@[@"i",@"i",@"i",@"i"]];
    // 添加右侧索引样式
    DDIndexViewMode *mode = [[DDIndexViewMode alloc]initMakeIndexviewModel:^(DDIndexViewModel *make) {
        make.indexColor = [UIColor blackColor];
        make.indexBackgroundColor = [UIColor whiteColor];
        make.selectedColor = [UIColor whiteColor];
        make.selectedBackgroundColor = [UIColor blackColor];
    }];
    [self.testTableView addIndexViewStyleWithMode:mode];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArr[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    cell.textLabel.text = self.dataArr[indexPath.section][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"baichi.jpg"];

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i"];
}
//返回每个索引的内容
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [@[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i"] objectAtIndex:section];
}

//返回section的个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataArr.count;
}

@end
