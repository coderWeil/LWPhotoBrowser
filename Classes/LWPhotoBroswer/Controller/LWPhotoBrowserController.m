//
//  LWPhotoBrowserController.m
//  TransitionDemo
//
//  Created by weil on 2018/5/7.
//  Copyright © 2018年 weil. All rights reserved.
//

#import "LWPhotoBrowserController.h"
#import "LWPhotoModel.h"
#import "LWPhotoViewCell.h"

#define kBrowserSpace 50.0f
@interface LWPhotoBrowserController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LWPhotoViewCellDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,assign) CGPoint transitionImageViewCenter;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *page_indicator;
@property (nonatomic, assign) NSUInteger cur_index;
@property (nonatomic, assign) BOOL response_pan;
@end

@implementation LWPhotoBrowserController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showPageIndicator = NO;
        self.response_pan = NO;
    }
    return self;
}
- (void)loadView {
    [super loadView];
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_imageView];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundView = nil;
    [_collectionView registerClass:[LWPhotoViewCell class] forCellWithReuseIdentifier:NSStringFromClass([LWPhotoViewCell class])];
    [self.view addSubview:_collectionView];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_animatedTransition.photoBrowserTransition.transitionImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self prefersStatusBarHidden];
    _page_indicator = [UILabel new];
    _page_indicator.textColor = [UIColor whiteColor];
    _page_indicator.font = [UIFont systemFontOfSize:15.0];
    _page_indicator.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_page_indicator];
    self.cur_index = 0;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:pan];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.frame = CGRectMake(0, 0, LW_SCREENWIDTH + kBrowserSpace, LW_SCREENHEIGHT);
    self.page_indicator.frame = CGRectMake(0, self.view.bounds.size.height - 30 - 40, self.view.frame.size.width, 30);
    self.page_indicator.hidden = !self.showPageIndicator;
    self.cur_index = self.animatedTransition.photoBrowserTransition.transitionImageIndex;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.cur_index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}
- (void)reload {
    [self.collectionView reloadData];
    self.page_indicator.text = [NSString stringWithFormat:@"%d / %d", self.cur_index + 1, self.photosArray.count];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photosArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(self.view.frame.size.width + kBrowserSpace, self.view.frame.size.height);
    return size;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWPhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LWPhotoViewCell class]) forIndexPath:indexPath];
    [cell updateCellWithModel:_photosArray[indexPath.item]];
    cell.delegate = self;
    cell.index = indexPath.item;
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offset = _collectionView.contentOffset.x;
    NSInteger index = offset / (LW_SCREENWIDTH + kBrowserSpace);
    [self setupViewControllerProperty:index];
    if (self.scrollToIndex) {
        self.scrollToIndex(index);
    }
    self.cur_index = index;
    self.page_indicator.text = [NSString stringWithFormat:@"%d / %d", self.cur_index + 1, self.photosArray.count];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //取消单击事件
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:self.cur_index inSection:0];
    LWPhotoViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexpath];
    [cell.photoZoomView cancelTapEvent];
}
- (void)setupViewControllerProperty:(NSInteger)index {
    LWPhotoViewCell *cell = (LWPhotoViewCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    _animatedTransition.photoBrowserTransition.transitionImage = cell.photoZoomView.zoomImageView.image;
    _animatedTransition.photoBrowserTransition.transitionImageIndex = index;
    _imageView.frame = cell.photoZoomView.zoomImageView.frame;
    _imageView.image = cell.photoZoomView.zoomImageView.image;
    _imageView.hidden = YES;
    _transitionImageViewCenter = _imageView.center;
}
- (void)didClickImageView:(NSInteger)index {
    if (!self.response_pan) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)panAction:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    CGFloat scale = 1- (fabsf(translation.y) / LW_SCREENHEIGHT);
    scale = scale < 0 ? 0 : scale;
    scale = scale > 1 ? 1 : scale;
    switch (gesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
        {
            self.response_pan = YES;
            [self setupViewControllerProperty:_animatedTransition.photoBrowserTransition.transitionImageIndex
             ];
            _collectionView.hidden = YES;
            _imageView.hidden = NO;
            _animatedTransition.photoBrowserTransition.panGestureRecognizer = gesture;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case UIGestureRecognizerStateChanged:
            _imageView.center = CGPointMake(_transitionImageViewCenter.x + translation.x * scale, _transitionImageViewCenter.y + translation.y);
            _imageView.transform = CGAffineTransformMakeScale(scale, scale);
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if (scale > 0.8f) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.imageView.center = self.transitionImageViewCenter;
                    self.imageView.transform = CGAffineTransformMakeScale(1, 1);
                } completion:^(BOOL finished) {
                    self.imageView.transform = CGAffineTransformIdentity;
                }];
            }
            self.animatedTransition.photoBrowserTransition.transitionImage = self.imageView.image;
            self.animatedTransition.photoBrowserTransition.currentPanGesImageFrame = self.imageView.frame;
            self.animatedTransition.photoBrowserTransition.panGestureRecognizer = nil;
            self.response_pan = NO;
            self.collectionView.hidden = NO;
        }
        default:
            break;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
