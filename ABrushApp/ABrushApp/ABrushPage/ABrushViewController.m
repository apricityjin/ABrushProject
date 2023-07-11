//
//  ABrushViewController.m
//  ABrushApp
//
//  Created by apricity on 2023/6/9.
//

#import "ABrushViewController.h"

#import "APath/PathViewController.h"
#import "Gradient/GradientViewController.h"

@interface ABrushViewController ()
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSArray *> * dataAry;

@end

@implementation ABrushViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

#pragma mark - table view delegate & data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataAry[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataAry[indexPath.section][indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController * vc;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            vc = [[PathViewController alloc] init];
        } else if (indexPath.row == 1) {
            vc = [[GradientViewController alloc] init];
        }
    }
    vc.title = self.dataAry[indexPath.section][indexPath.row];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        
    }
    return _tableView;
}

- (NSArray *)dataAry
{
    if (_dataAry == nil) {
        _dataAry = @[
            @[@"Gradient Linear",
              @"Gradient Radial"],
        ];
    }
    return _dataAry;
}

@end
