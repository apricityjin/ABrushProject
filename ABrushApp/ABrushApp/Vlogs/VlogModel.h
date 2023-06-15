//
//  VlogModel.h
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VlogModel : NSObject

@property (strong, nonatomic) NSURL * URL;
@property (strong, nonatomic) NSURL * thumbURL;
@property (copy, nonatomic) NSString * title;
@property (copy, nonatomic) NSString * subtitle;

+ (NSMutableArray <VlogModel *> *)getVlogModels;

@end

NS_ASSUME_NONNULL_END
