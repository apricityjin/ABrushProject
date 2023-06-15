//
//  ShowImagesCollectionViewCell.h
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import <UIKit/UIKit.h>
#import "ShowImagesModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShowImagesCollectionViewCell : UICollectionViewCell

@property (assign, nonatomic, getter=isBedinEditing) BOOL beginEditing;
@property (strong, nonatomic) UIImageView * imageView;

@end

NS_ASSUME_NONNULL_END
