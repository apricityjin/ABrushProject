//
//  VlogModel.m
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import "VlogModel.h"

@implementation VlogModel

- (instancetype)initWithURL:(NSURL *)URL
                   thumbURL:(NSURL *)thumbURL
                      title:(NSString *)title
                   subtitle:(NSString *)subtitle
{
    self = [super init];
    if (self) {
        self.URL = URL;
        self.thumbURL = thumbURL;
        self.title = title;
        self.subtitle = subtitle;
    }
    return self;
}

+ (NSMutableArray <VlogModel *> *)getVlogModels {
    NSArray * names = @[@"newYorkFlip",
                        @"bulletTrain",
                        @"monkey",
                        @"shark"];
    NSArray * titles = @[@"New York Flip",
                         @"Bullet Train Adventure",
                         @"Monkey Village",
                         @"Robot Battles"];
    NSArray * subtitles = @[@"Can this guys really flip all of his bros? You'll never believe what happens!",
                            @"Enjoying the soothing view of passing towns in Japan",
                            @"Watch as a roving gang of monkeys terrorizes the top of this mountain!",
                            @"Have you ever seen a robot shark try to eat another robot?"];
    NSMutableArray * mAry = [NSMutableArray array];
    [names enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * URLPath = [NSBundle.mainBundle pathForResource:obj ofType:@"mp4"];
        NSString * thumbURLPath = [NSBundle.mainBundle pathForResource:obj ofType:@"png"];
        NSURL * URL = [NSURL fileURLWithPath:URLPath];
        NSURL * thumbURL = [NSURL fileURLWithPath:thumbURLPath];
        VlogModel * model = [[VlogModel alloc] initWithURL:URL
                                                  thumbURL:thumbURL
                                                     title:titles[idx]
                                                  subtitle:subtitles[idx]];
        [mAry addObject:model];
    }];
    return mAry;
}



@end



