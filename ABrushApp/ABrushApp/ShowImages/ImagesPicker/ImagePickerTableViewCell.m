//
//  ImagePickerTableViewCell.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ImagePickerTableViewCell.h"
#import "Masonry.h"
#import "ImageDownloader.h"

@interface ImagePickerTableViewCell ()

@property (strong, nonatomic) UIImageView * titleImageView;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel * numberLabel;
@property (strong, nonatomic) UIImageView * arrowImageView;

@end

@implementation ImagePickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutMyViews];
    }
    return self;
}

- (void)layoutMyViews {
    [self.contentView addSubview:self.titleImageView];
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.top.mas_equalTo(self.contentView).mas_offset(15);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-15);
        make.height.width.mas_equalTo(80);
    }];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleImageView.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.titleImageView);
    }];
    [self.contentView addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleImageView.mas_centerY);
    }];
    [self.contentView addSubview:self.arrowImageView];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

#pragma mark - setter

- (void)setCellModel:(ImagesModel *)cellModel {
    _cellModel = cellModel;
    self.titleImageView.image = cellModel.image;
    [self.arrowImageView setImage:[UIImage systemImageNamed:@"arrow.right"]];
    self.titleLabel.text = cellModel.title;
    self.numberLabel.text = [NSString stringWithFormat:@"%zd", cellModel.number];
}

#pragma mark - getter

- (UIImageView *)titleImageView {
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] initWithFrame:(CGRectMake(0, 0, 0, 0))];
        _titleImageView.layer.cornerRadius = 15;
        _titleImageView.layer.masksToBounds = YES;
        _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _titleImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _titleLabel.numberOfLines = 0;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)numberLabel {
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:16];
        _numberLabel.numberOfLines = 0;
        [_numberLabel sizeToFit];
    }
    return _numberLabel;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"arrow.right"]];
        [_arrowImageView sizeToFit];
    }
    return _arrowImageView;
}

@end
