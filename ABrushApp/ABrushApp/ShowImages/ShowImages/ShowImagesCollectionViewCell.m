//
//  ShowImagesCollectionViewCell.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ShowImagesCollectionViewCell.h"
#import "Masonry.h"
#import "ImageDownloader.h"

@interface ShowImagesCollectionViewCell ()


@property (strong, nonatomic) UIImageView * selectingImageView;

@end

@implementation ShowImagesCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutMyViews];
    }
    return self;
}

- (void)layoutMyViews {
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.selectingImageView];
    [self.selectingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

#pragma mark - setter

- (void)setBeginEditing:(BOOL)editing {
    _beginEditing = editing;
    self.selectingImageView.hidden = !editing;
}

#pragma mark - getter

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.cornerRadius = 10;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)selectingImageView {
    if (_selectingImageView == nil) {
        _selectingImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle"] highlightedImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
    }
    return _selectingImageView;
}

@end
