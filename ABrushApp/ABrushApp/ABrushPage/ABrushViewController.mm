//
//  ABrushViewController.m
//  ABrushApp
//
//  Created by apricity on 2023/6/9.
//

#import "ABrushViewController.h"
#import "TestView.h"

@interface ABrushViewController ()

@property (nonatomic, strong) TestView * testView;

@end

@implementation ABrushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.testView = [[TestView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.testView];
}


@end
