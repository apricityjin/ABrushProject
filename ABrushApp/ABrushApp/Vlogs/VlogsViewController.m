//
//  VlogsViewController.m
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import "VlogsViewController.h"
#import "VlogTableViewCell.h"
#import "VlogModel.h"
#import "VlogDetailsViewController.h"

@interface VlogsViewController ()
<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView * tableView;

@property (strong, nonatomic) NSMutableArray <VlogModel *> * dataMAry;

@property (strong, nonatomic) CADisplayLink * displayLink;

@end

@implementation VlogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Vlogs";
    self.view.backgroundColor = UIColor.whiteColor;
    [self loadData];
    [self layoutMyViews];
//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(ddd)];
    [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)ddd {
    NSLog(@"%f---%f", self.displayLink.timestamp, self.displayLink.duration);
}

- (void)loadData {
    self.dataMAry = [VlogModel getVlogModels];
}

- (void)layoutMyViews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VlogDetailsViewController * vlogDetailsVC = [[VlogDetailsViewController alloc] initWithVlogModels:self.dataMAry currentVlogIndex:indexPath.row];
    [self presentViewController:vlogDetailsVC animated:YES completion:^{

    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataMAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VlogTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:VlogTableViewCell.reusableIdentifier forIndexPath:indexPath];
    
    cell.cellModel = self.dataMAry[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [VlogTableViewCell heightForVlogModel:self.dataMAry[indexPath.row]];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        [_tableView registerClass:VlogTableViewCell.class forCellReuseIdentifier:VlogTableViewCell.reusableIdentifier];
    }
    return _tableView;
}

@end
