//
//  VlogPlayerViewController.h
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "VlogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VlogDetailsViewController : UIViewController

- (instancetype)initWithVlogModels:(NSMutableArray<VlogModel *> *)dataMAry currentVlogIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
