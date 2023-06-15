//
//  BottomView.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/19.
//

#import "BottomView.h"
#import "Masonry.h"

@interface BottomView ()

@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UIButton * deleteButton;

@end

@implementation BottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self layoutMyViews];
    }
    return self;
}

- (void)layoutMyViews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.deleteButton];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_offset(20);
        make.right.mas_lessThanOrEqualTo(self.deleteButton.mas_left);
        make.bottom.mas_lessThanOrEqualTo(self.mas_bottom).mas_offset(-20);
    }];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_lessThanOrEqualTo(self.deleteButton.mas_right);
        make.right.mas_offset(-20);
        make.bottom.mas_lessThanOrEqualTo(self.mas_bottom).mas_offset(-20);
    }];
}

- (void)updateSelectedCount:(NSInteger)count {
    self.titleLabel.text = [NSString stringWithFormat:@" 已选择 %zd 项 ", count];
}

#pragma mark - event action

- (void)deleteButtonDidClicked {
    if ([self.delegate respondsToSelector:@selector(deleteButtonDidClicked)]) {
        [self.delegate deleteButtonDidClicked];
    }
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:(CGRectZero)];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.numberOfLines = 0;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] initWithFrame:(CGRectZero)];
        [_deleteButton setTitle:@"  删除  " forState:(UIControlStateNormal)];
        [_deleteButton setTitleColor:UIColor.blackColor forState:(UIControlStateNormal)];
        [_deleteButton setBackgroundColor:UIColor.lightGrayColor];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _deleteButton.titleLabel.numberOfLines = 0;
        _deleteButton.layer.cornerRadius = 10;
        [_deleteButton sizeToFit];
        [_deleteButton addTarget:self action:@selector(deleteButtonDidClicked) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _deleteButton;
}

@end
