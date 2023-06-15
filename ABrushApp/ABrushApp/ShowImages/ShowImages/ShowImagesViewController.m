//
//  ShowImagesViewController.m
//  DemoShowImages
//
//  Created by apricity on 2023/5/18.
//

#import "ShowImagesViewController.h"
#import "ShowImagesCollectionViewCell.h"
#import "ShowImagesModel.h"
#import "Masonry.h"
#import "BottomView.h"
#import "ImageDownloader.h"
#import "ImageBrowseViewController.h"

@interface ShowImagesViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BottomViewDelegate>

@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout * collectionViewLayout;

@property (strong, nonatomic) UIBarButtonItem * rightBarButtonItem;
@property (strong, nonatomic) BottomView * bottomView;

@property (strong, nonatomic) NSMutableArray <ShowImagesModel *> * dataMAry;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger number;

@end

@implementation ShowImagesViewController

#pragma mark - life cycle

- (instancetype)initWithRow:(NSInteger)row
                     number:(NSInteger)number
{
    self = [super init];
    if (self) {
        self.row = row;
        self.number = number;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self layoutMyViews];
}

- (void)loadData {
    self.dataMAry = [ShowImagesModel getShowImagesModelsWithNumber:self.number row:self.row];

    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSThread currentThread]);
        [self.collectionView reloadData];
    });
}

- (void)layoutMyViews {
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    self.bottomView.hidden = YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataMAry.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ShowImagesCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ShowImagesCollectionViewCell.class) forIndexPath:indexPath];
    
    
    cell.imageView.image = [self.dataMAry objectAtIndex:indexPath.row].image;
//    [cell.imageView setNeedsDisplay];
    cell.beginEditing = self.isEditing;

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        [self.bottomView updateSelectedCount:self.collectionView.indexPathsForSelectedItems.count];
    } else {
        ImageBrowseViewController * vc = [[ImageBrowseViewController alloc] init];
        NSMutableArray * mAry = [NSMutableArray array];
        [self.dataMAry enumerateObjectsUsingBlock:^(ShowImagesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mAry addObject:obj.image];
        }];
        vc.imageAry = mAry.copy;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.indexPath = indexPath;
        
        [self presentViewController:vc
                           animated:YES
                         completion:^{
        }];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.bottomView updateSelectedCount:self.collectionView.indexPathsForSelectedItems.count];
}

#pragma mark - UICollectionViewDelegateFlowLayout

static const float kSeperatorLineWidth = 15;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (UIScreen.mainScreen.bounds.size.width - kSeperatorLineWidth * 4) / 3;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kSeperatorLineWidth, kSeperatorLineWidth, kSeperatorLineWidth, kSeperatorLineWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSeperatorLineWidth;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kSeperatorLineWidth;
}

#pragma mark - BottomViewDelegate

- (void)deleteButtonDidClicked {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"删除" message:[NSString stringWithFormat:@"是否删除选中的 %zd 项", self.collectionView.indexPathsForSelectedItems.count] preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction * sureAction = [UIAlertAction
                                  actionWithTitle:@"确定"
                                  style:(UIAlertActionStyleDefault)
                                  handler:^(UIAlertAction * _Nonnull action) {
        NSMutableIndexSet * indexes = [NSMutableIndexSet indexSet];
        for (NSIndexPath * indexPath in self.collectionView.indexPathsForSelectedItems) {
            [indexes addIndex:indexPath.row];
        }
        [self.dataMAry removeObjectsAtIndexes:indexes];
        [self.collectionView reloadData];
        [self.delegate deleteImagesWithRow:self.row count:indexes.count];
        [self rightBarButtonItemDidClicked];
        if (self.dataMAry.count <= 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [ac addAction:sureAction];
    [ac addAction:cancelAction];
    
    [self presentViewController:ac
                       animated:YES
                     completion:nil];
}

#pragma mark - event action

- (void)rightBarButtonItemDidClicked {
    if (self.isEditing) { // end
        self.rightBarButtonItem.title = @"管理";
        self.bottomView.hidden = YES;
        [self setEditing:NO animated:YES];
        self.collectionView.allowsMultipleSelection = NO;
    } else { // start
        self.rightBarButtonItem.title = @"完成";
        self.bottomView.hidden = false;
        [self setEditing:YES animated:YES];
        self.collectionView.allowsMultipleSelection = YES;
    }
    [self.bottomView updateSelectedCount:self.collectionView.indexPathsForSelectedItems.count];
    [self.collectionView reloadData];
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColor.whiteColor;
        [_collectionView registerClass:ShowImagesCollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(ShowImagesCollectionViewCell.class)];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (_collectionViewLayout == nil) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _collectionViewLayout;
}

- (NSMutableArray<ShowImagesModel *> *)dataMAry {
    if (_dataMAry == nil) {
        _dataMAry = [NSMutableArray array];
    }
    return _dataMAry;
}

- (UIBarButtonItem *)rightBarButtonItem {
    if (_rightBarButtonItem == nil) {
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItemDidClicked)];
        
    }
    return _rightBarButtonItem;
}

- (BottomView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[BottomView alloc] initWithFrame:(CGRectZero)];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

@end
