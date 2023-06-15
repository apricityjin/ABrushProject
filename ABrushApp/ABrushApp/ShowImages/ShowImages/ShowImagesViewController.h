//
//  ShowImagesViewController.h
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ShowImagesViewControllerDelegate <NSObject>

- (void)deleteImagesWithRow:(NSInteger)row count:(NSInteger)count;

@end

@interface ShowImagesViewController : UIViewController

@property (weak, nonatomic) id <ShowImagesViewControllerDelegate> delegate;

- (instancetype)initWithRow:(NSInteger)row number:(NSInteger)number;

@end

NS_ASSUME_NONNULL_END
