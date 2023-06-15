//
//  VlogTableViewCell.m
//  MyAVPlayer
//
//  Created by apricity on 2023/5/25.
//

#import "VlogTableViewCell.h"

@interface VlogTableViewCell ()

@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel * subtitleLabel;
@property (strong, nonatomic) UIImageView * previewImageView;

@property (assign, nonatomic) CGFloat padding;
@property (assign, nonatomic) CGFloat maxWidth;
@property (assign, nonatomic) CGFloat previewHeight;

@end

@implementation VlogTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.padding = 10;
        self.maxWidth = UIScreen.mainScreen.bounds.size.width - self.padding * 2;
        self.previewHeight = self.maxWidth / 16 * 9;
        [self layoutMyViews];
    }
    return self;
}

- (void)layoutMyViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.previewImageView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_offset(self.padding);
        make.right.mas_offset(-self.padding);
    }];
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(self.padding);
        make.right.mas_offset(-self.padding);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(self.padding);
        make.height.mas_equalTo(self.previewHeight);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(self.padding);
        make.right.mas_offset(-self.padding);
        make.top.mas_equalTo(self.previewImageView.mas_bottom).mas_offset(self.padding);
        make.bottom.mas_offset(-self.padding);
    }];
}

+ (CGFloat)heightForVlogModel:(VlogModel *)vlogModel {
    CGFloat padding = 10;
    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - padding * 2;
    CGFloat previewHeight = maxWidth / 16 * 9;
    
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:24];
    label.text = vlogModel.title;
    CGFloat titleHeight = [label sizeThatFits:CGSizeMake(maxWidth, INFINITY)].height;
    
    label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18];
    label.numberOfLines = 2;
    label.text = vlogModel.title;
    CGFloat subtitleHeight = [label sizeThatFits:CGSizeMake(maxWidth, INFINITY)].height;
    
    return padding + titleHeight + padding + previewHeight + padding + subtitleHeight + padding;
}

+ (NSString *)reusableIdentifier {
    return NSStringFromClass(self.class);
}

#pragma mark - setter

- (void)setCellModel:(VlogModel *)cellModel {
    _cellModel = cellModel;
    self.titleLabel.text = cellModel.title;
    self.subtitleLabel.text = cellModel.subtitle;
    self.previewImageView.image = [UIImage imageNamed:cellModel.thumbURL.path];
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:24];
        _titleLabel.numberOfLines = 1;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == nil) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:18];
        _subtitleLabel.numberOfLines = 2;
        [_subtitleLabel sizeToFit];
    }
    return _subtitleLabel;
}

- (UIImageView *)previewImageView {
    if (_previewImageView == nil) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
    }
    return _previewImageView;
}

@end
