//
//  TexImgViewController.m
//  ABrushApp
//
//  Created by Apricity on 2023/7/12.
//

#import "TexImgViewController.h"

#import "ABrush.hpp"
using namespace ABrush;

@interface TexImgViewController ()

@end

@implementation TexImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    std::string filePath = "/Users/ediothjin/Desktop/iShot_2023-07-12_15.09.04.png";
    Image img = Image(filePath, 4);
    
}

@end
