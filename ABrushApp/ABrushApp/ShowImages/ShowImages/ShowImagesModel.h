//
//  ShowImagesModel.h
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShowImagesModel : NSObject

@property (strong, nonatomic) UIImage * image;
@property (assign, nonatomic, getter=isSelected) BOOL selected;

+ (NSMutableArray <ShowImagesModel *> *)getShowImagesModelsWithNumber:(NSInteger)number row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
