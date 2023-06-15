//
//  ImageDownloader.h
//  test
//
//  Created by apricity on 2023/5/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageDownloader : NSObject
<NSURLSessionDelegate, NSURLSessionDataDelegate>

//+ (instancetype)sharedImageDownloader;

- (void)downloadImageFromURL:(NSURL *)url
             completionBlock:(void (^)(UIImage * image))completion;

@end

NS_ASSUME_NONNULL_END
