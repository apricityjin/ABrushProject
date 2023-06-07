//
//  ViewController.m
//  ABrushDemo
//
//  Created by apricity on 2023/6/7.
//

#import "ViewController.h"
#import "DemoView.h"

//#import "Point.hpp"
#include "ABrush.hpp"

@interface ViewController ()

@property (strong, nonatomic) DemoView * demoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.demoView = [[DemoView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:self.demoView];
}

@end
