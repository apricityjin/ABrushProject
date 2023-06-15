//
//  ImageBrowseCollectionViewCell.m
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/20.
//

#import "ImageBrowseCollectionViewCell.h"
#import "Masonry.h"

@interface ImageBrowseCollectionViewCell ()
<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView * scrollView;
@property (strong, nonatomic) UIImageView * imageView;

@property (assign, nonatomic) CGFloat ratio;

@end

@implementation ImageBrowseCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self layoutMyViews];
    }
    return self;
}

- (void)setup {
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTap];
    
}

- (void)layoutMyViews {
    
    [self.contentView addSubview:self.scrollView];
//    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.contentView);
//    }];
    self.scrollView.frame = self.contentView.frame;
//    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width + 1,  self.contentView.frame.size.height + 1);
    
    [self.scrollView addSubview:self.imageView];
    self.imageView.frame = self.contentView.frame;
}

//- (void)adjustFrameWithScale:(CGFloat)scale {
//    CGFloat x = 0;
//    CGFloat y = 0;
//    CGFloat width = self.contentView.frame.size.width;
//    CGFloat height = self.contentView.frame.size.width * self.ratio;
//    if (self.ratio > 1 && height > self.contentView.frame.size.height) {
//        // 长图片、高度大于屏幕可以显示的高度
//        width = self.contentView.frame.size.height / self.ratio;
//        height = self.contentView.frame.size.height;
//        x = (self.contentView.frame.size.width - width) / 2;
//    } else {
//        y = (self.contentView.frame.size.height - height) / 2;
//    }
//
//    if (scale > 1) {
//        width = width * scale;
//        height = height * scale;
//        if (width < self.contentView.frame.size.width) {
//
//        } else {
//            x = 0;
//            y = 0;
//        }
//    }
//    [UIView animateWithDuration:0.3 animations:^{
//        self.imageView.frame = CGRectMake(x, y, width, height);
//    }];
//    self.scrollView.contentSize = CGSizeMake(width + 1, height + 1);
//}

#pragma mark - gesture

- (void)tapAction:(UITapGestureRecognizer *)recognizer {
    
    UIScrollView * scrollView = (UIScrollView *)recognizer.view;
    if (scrollView.zoomScale > 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
//        [self adjustFrameWithScale:1.0];
    }else {
        
        CGFloat scale = 3.0;
        
//        if (self.ratio > 1) {
//            scale = self.contentView.frame.size.width / self.imageView.frame.size.width;
//        } else {
//            scale = self.contentView.frame.size.height / self.imageView.frame.size.height;
//        }
//        [self adjustFrameWithScale:scale];
        [scrollView setZoomScale:scale animated:YES];
//        CGPoint pt = [recognizer locationInView:self.scrollView];
//        CGRect rect = self.scrollView.frame;
//        CGAffineTransform tr = CGAffineTransformIdentity;
//        tr = CGAffineTransformTranslate(tr, -pt.x, -pt.y);
//        tr = CGAffineTransformScale(tr, 1/scale, 1/scale);
//        tr = CGAffineTransformTranslate(tr, pt.x, pt.y);
//
//        rect = CGRectApplyAffineTransform(rect, tr);
//
//        [scrollView zoomToRect:rect animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    CGFloat scale = scrollView.zoomScale;
//        [self adjustFrameWithScale:scale];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"");
}

#pragma mark - setter

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
    self.ratio = image.size.height / image.size.width;
//    self.scrollView.zoomScale = 1.0;
//    [self adjustFrameWithScale:1.0];
}

#pragma mark - getter

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.bouncesZoom = YES;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 4.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end
