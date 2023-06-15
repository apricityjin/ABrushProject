//
//  ImagePickerTableViewCell.h
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import <UIKit/UIKit.h>
#import "ImagesModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImagePickerTableViewCell : UITableViewCell

@property (nonatomic, strong) ImagesModel * cellModel;

@end

NS_ASSUME_NONNULL_END
