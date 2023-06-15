//
//  ImageBrowseViewController.m
//  DemoImageMagenification
//
//  Created by apricity on 2023/5/20.
//

#import "ImageBrowseViewController.h"
#import "ImageBrowseCollectionViewCell.h"
#import "Masonry.h"

@interface ImageBrowseViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout * flowLayout;

@property (strong, nonatomic) UIButton * xmarkButton;
@property (strong, nonatomic) UILabel * titleLabel;

@end

@implementation ImageBrowseViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self layoutMyViews];
}

- (void)layoutMyViews {
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.xmarkButton];
    [self.xmarkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(44);
    }];
    
    [self.view layoutIfNeeded];
    
    [self.collectionView scrollToItemAtIndexPath:self.indexPath
                                atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally)
                                        animated:NO];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger row = 1.5 + self.collectionView.contentOffset.x / self.view.frame.size.width;
    self.titleLabel.text = [NSString stringWithFormat:@"%zd / %zd", row, self.imageAry.count];
    self.indexPath = [NSIndexPath indexPathWithIndex:row];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageAry.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageBrowseCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ImageBrowseCollectionViewCell.class) forIndexPath:indexPath];
    
    cell.image = self.imageAry[indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - event action

- (void)xmarkButtonDidClicked {
    [self dismissViewControllerAnimated:YES
                             completion:^{
        
    }];
}

#pragma mark - setter

- (void)setImageAry:(NSArray *)images {
    _imageAry = images;
    [self.collectionView reloadData];
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.userInteractionEnabled = YES;
        [_collectionView registerClass:ImageBrowseCollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(ImageBrowseCollectionViewCell.class)];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UIButton *)xmarkButton {
    if (_xmarkButton == nil) {
        _xmarkButton = [[UIButton alloc] init];
        [_xmarkButton addTarget:self
                         action:@selector(xmarkButtonDidClicked)
               forControlEvents:(UIControlEventTouchUpInside)];
        [_xmarkButton setImage:[UIImage systemImageNamed:@"xmark"]
                      forState:(UIControlStateNormal)];
    }
    return _xmarkButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = [NSString stringWithFormat:@"1 / %zd", self.imageAry.count];
    }
    return _titleLabel;
}

@end
