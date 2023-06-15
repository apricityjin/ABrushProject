//
//  ImagesModel.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ImagesModel.h"
#import "ImageDownloader.h"

@implementation ImagesModel

+ (NSArray<ImagesModel *> *)getImagesModels {
    NSArray<NSDictionary *>* models = @[
        @{
            @"title": @"插画",
            @"number": @30,
            @"imageName":@"https://t7.baidu.com/it/u=1819248061,230866778&fm=193&f=GIF"
        },
        @{
            @"title": @"皮影戏",
            @"number": @20,
            @"imageName":@"https://t7.baidu.com/it/u=2168645659,3174029352&fm=193&f=GIF"
        },
        @{
            @"title": @"宠物",
            @"number": @13,
            @"imageName":@"https://t7.baidu.com/it/u=1831997705,836992814&fm=193&f=GIF"
        }];
    NSMutableArray * mAry = [NSMutableArray array];
    for (NSDictionary * model in models) {
        ImagesModel * m = [[ImagesModel alloc] init];
        NSURL * url = [NSURL URLWithString:[model objectForKey:@"imageName"]];
        [[ImageDownloader new]
         downloadImageFromURL:url
         completionBlock:^(UIImage * _Nonnull image) {
            m.image = image;
        }];
        m.title = [model valueForKey:@"title"];
        m.number = [[model valueForKey:@"number"] intValue];
        [mAry addObject:m];
    }
    
    return [mAry copy];
}

@end
