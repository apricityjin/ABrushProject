//
//  ShowImagesModel.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ShowImagesModel.h"
#import "ImageDownloader.h"

@implementation ShowImagesModel

+ (NSMutableArray<ShowImagesModel *> *)getShowImagesModelsWithNumber:(NSInteger)number
                                                                 row:(NSInteger)row {
    NSMutableArray * mAry = [NSMutableArray arrayWithCapacity:number];
    NSString * imageName;
    if (row == 0) {
        imageName = @"https://t7.baidu.com/it/u=1819248061,230866778&fm=193&f=GIF";
    } else if (row == 1) {
        imageName = @"https://t7.baidu.com/it/u=2168645659,3174029352&fm=193&f=GIF";
    } else if (row == 2) {
        imageName = @"https://t7.baidu.com/it/u=1831997705,836992814&fm=193&f=GIF";
    }
    for (int i = 0; i < number; i++) {
        dispatch_async(dispatch_queue_create("com.test", DISPATCH_QUEUE_SERIAL), ^{
            ShowImagesModel * model = [[ShowImagesModel alloc] init];
            NSURL * url = [NSURL URLWithString:imageName];
            [[ImageDownloader new]
             downloadImageFromURL:url
             completionBlock:^(UIImage * _Nonnull image) {
                model.image = image;
            }];
            model.selected = NO;
            [mAry addObject:model];
        });
    }
    
    return mAry;
}

@end
