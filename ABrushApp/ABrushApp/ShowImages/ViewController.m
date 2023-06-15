//
//  ViewController.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ImagesPicker/ImagesTableViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton * button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"跳转页面";
    [self layoutMyViews];
}

- (void)layoutMyViews {
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
    }];
}

#pragma - event action

- (void)jumpShowImagesController {
    [self.navigationController pushViewController:[[ImagesTableViewController alloc] initWithStyle:(UITableViewStylePlain)] animated:YES];
    
}

#pragma - lazy

- (UIButton *)button {
    if (_button == nil) {
        _button = [[UIButton alloc] init];
        _button.backgroundColor = UIColor.greenColor;
        [_button setTitle:@"Jump to next controller"
                 forState:(UIControlStateNormal)];
        [_button setTitleColor:UIColor.blackColor
                      forState:(UIControlStateNormal)];
        [_button sizeToFit];
        [_button addTarget:self
                    action:@selector(jumpShowImagesController)
          forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _button;
}

@end
