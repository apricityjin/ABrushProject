//
//  ImageDownloader.m
//  test
//
//  Created by apricity on 2023/5/23.
//

#import "ImageDownloader.h"


// key: session.hash value: blocks
static NSMutableDictionary<NSString *, NSMutableArray<ImageDownloader *>*>* mDic;

@interface ImageDownloader ()

@property (strong, nonatomic) NSURL * url;
@property (copy, nonatomic) void(^completionBlock)(UIImage * image);
@property (copy, nonatomic) NSString * imagePath;

@end

@implementation ImageDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (mDic == nil) {
            mDic = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)downloadImageFromURL:(NSURL *)url
             completionBlock:(void (^)(UIImage * image))completion {
    NSLog(@"%@", [NSThread currentThread]);
    // 先从本地获取
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    self.imagePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.png", url.hash]];
    UIImage * image = [UIImage imageWithContentsOfFile:self.imagePath];
    if (image) {
        completion(image);
        return; // 可以正常读取图片、释放内存
    }
    // 本地无缓存，则进行网络请求获取图片
    if (completion) {
        self.completionBlock = completion;
    }
    if (url) {
        self.url = url;
    }
    // 避免同一url进行多次网络请求
    NSMutableArray * mAry = [mDic objectForKey:[NSString stringWithFormat:@"%lu.png", url.hash]];
    if (mAry) {
        [mAry addObject:self];
        return;
    } else { //
        mAry = [NSMutableArray array];
        [mAry addObject:self];
        [mDic setObject:mAry forKey:[NSString stringWithFormat:@"%lu.png", url.hash]];
    }
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [data writeToFile:self.imagePath options:NSDataWritingAtomic error:nil];
    UIImage * image = [UIImage imageWithData:data];
    NSMutableArray * mAry = [mDic objectForKey:[NSString stringWithFormat:@"%lu.png", self.url.hash]];
    for (ImageDownloader * idler in mAry) {
        if (image && idler.completionBlock) {
            idler.completionBlock(image);
        }
    }
    [mDic removeObjectForKey:[NSString stringWithFormat:@"%lu.png", self.url.hash]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    }
}

@end
