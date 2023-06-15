//
//  VlogTableViewCell.h
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import <UIKit/UIKit.h>
#import "VlogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VlogTableViewCell : UITableViewCell

@property (strong, nonatomic) VlogModel * cellModel;

+ (CGFloat)heightForVlogModel:(VlogModel *)vlogModel;
+ (NSString *)reusableIdentifier;

@end

NS_ASSUME_NONNULL_END
