//
//  ViewController.m
//  LQRefreshDemo
//
//  Created by hongzhiqiang on 2018/11/12.
//  Copyright © 2018 hhh. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "LQRefresh.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger cellNum;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    window.rootViewController = nav;
    self.navigationItem.title = @"测试刷新";
    self.cellNum = 5;
    [self setupUI];
    self.tableView.contentInsetAdjustmentBehavior = NO;
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset = 0;
    }];
}

#pragma mark - tableViewDelegate && tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    cell.backgroundColor = [UIColor orangeColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        //_tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
         //block的方式创建刷新头
        /*
        __weak typeof(self)wself = self;
        _tableView.lq_header = [LQRefreshHeader headerWithRefreshBlock:^{
            //模拟正在刷新数据
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        __weak.cellNum = arc4random() % 5 +1;
                        [__weak.tableView reloadData];
                        [__weak.tableView.lq_header endRefresh];
            });
        }];
        */
        
        //添加方法的形式创建刷新头
        _tableView.lq_header = [LQRefreshHeader headerWithRefreshTarge:self refreshAction:@selector(loadNewData)];
    }
    return _tableView;
}

- (void)loadNewData {
    //模拟正在刷新数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.cellNum = arc4random() % 5 +1;
        [self.tableView reloadData];
        [self.tableView.lq_header endRefresh];
    });
}

@end
