//
//  ImageBrowseViewController.h
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageBrowseViewController : UIViewController

@property (strong, nonatomic) NSArray <UIImage *> * imageAry;
@property (strong, nonatomic) NSIndexPath * indexPath;

@end

NS_ASSUME_NONNULL_END
