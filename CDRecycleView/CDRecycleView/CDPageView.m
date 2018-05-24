//
//  CDPageView.m
//  CDRecycleView
//
//  Created by 车德超 on 2018/5/22.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import "CDPageView.h"
#import "NSTimer+SafeTimer.h"

static NSString *const kRecycleCellIdentifier = @"RecycleCellIdentifier";
static int const kDefaultPageInterval = 2;

@interface CDPageViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation CDPageViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor blackColor];
        [self.contentView addSubview:_label];
        _label.frame = CGRectMake(10, 10, 100, 12);
    }
    return self;
}
@end

@interface CDPageView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
@end

@implementation CDPageView
{
    UICollectionView *_collectionView;
    UIPanGestureRecognizer *_pan;
    NSUInteger _totalCount;
    NSUInteger _visiableCount;
    CGFloat _lastTranslation;
    CGFloat _lastContentOffsetX;
    NSTimer *_timer;
    CGFloat _lastvelocity;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCollectionView];
        [self addPanGesture];
        [self addTimer];
    }
    return self;
}

- (void)createCollectionView {
    if (_collectionView) {
        return;
    }
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.scrollEnabled = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[CDPageViewCell class] forCellWithReuseIdentifier:kRecycleCellIdentifier];
    [self addSubview:_collectionView];
}

- (void)addPanGesture {
    if (_pan) {
        return;
    }
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_panGestureAction)];
    _pan.maximumNumberOfTouches = 1;
    _pan.delegate = self;
    [_collectionView addGestureRecognizer:_pan];
}

- (void)addTimer {
    if (_timer) {
        return;
    }
    _timer = [NSTimer safe_scheduledTimerWithTimeInterval:5 target:self selector:@selector(p_timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

#pragma mark - private custom page's effect
- (void)p_panGestureAction {
    UIGestureRecognizerState state = _pan.state;
    CGFloat translationX = [_pan translationInView:self].x;
    CGFloat velocity = [_pan velocityInView:self].x;
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            [self p_timerPause];
            _lastTranslation = 0;
            _lastvelocity = 0;
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGFloat contentOffsetX = _collectionView.contentOffset.x;
            CGFloat incrementTranslation = translationX - _lastTranslation;
            contentOffsetX -= incrementTranslation;
            if (contentOffsetX < _collectionView.contentSize.width + _collectionView.contentInset.right && contentOffsetX > 0 - _collectionView.contentInset.left) {
                [_collectionView setContentOffset:CGPointMake(contentOffsetX, _collectionView.contentOffset.y)];
            }
            _lastTranslation = translationX;
            _lastvelocity = velocity;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:{
            [self p_setPageNextScroll];
            [self p_timerStart];
        }
            break;
        default:
            [self p_setPageNextScroll];
            [self p_timerStart];
            break;
    }
}

#pragma mark - private

- (NSInteger)p_getDataIndex {
    CGFloat width = [self referenceDelta];
    NSInteger index = (int)(_collectionView.contentOffset.x + width * .5 - 1)/ width;
    NSInteger dataIndex = index;
    if (_isRecycle) {
        dataIndex = index == 0 ? _totalCount - 1 : (index == _totalCount + 1 ? 0 : index - 1);
    }
    return dataIndex;
}

- (void)p_setPageNextScroll {
    CGFloat contentOffsetX = _collectionView.contentOffset.x;
    int currentPage;
    if (contentOffsetX > _lastContentOffsetX) {
        currentPage = contentOffsetX / [self referenceDelta] + 1;
    } else {
        currentPage = contentOffsetX / [self referenceDelta];
    }
    
    CGFloat rcontentOffSetX = currentPage * [self referenceDelta];
    [_collectionView setContentOffset:CGPointMake(rcontentOffSetX, _collectionView.contentOffset.y) animated:YES];
    _lastContentOffsetX = _collectionView.contentOffset.x;
}

- (CGFloat)referenceDelta {
    return _r_size.width + _r_minimumLineSpacing;
}

- (void)p_numsOfCount {
    _visiableCount = (int) [_delegate numberOfItems];
    if (_isRecycle) {
        _totalCount = _visiableCount + 2;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
     _collectionView.contentOffset = CGPointMake([self referenceDelta], 0);
}

- (void)p_timerAction {
    CGFloat contentOffsetX = _collectionView.contentOffset.x;
    int currentPage = contentOffsetX / [self referenceDelta] + 1;
    CGFloat rcontentOffSetX = currentPage * [self referenceDelta];
    [_collectionView setContentOffset:CGPointMake(rcontentOffSetX, _collectionView.contentOffset.y) animated:YES];
    
}

- (void)p_timerPause {
    if (!_timer) {
        return;
    }
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)p_timerStop {
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
}

- (void)p_timerStart {
    if (!_timer) {
        return;
    }
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.interval]];
}

- (void)p_showCurrentPage {
    if ([_delegate respondsToSelector:@selector(currentPageIndex:)]) {
        NSInteger currentPage = [self p_getDataIndex];
        [_delegate currentPageIndex:currentPage];
    }
}

#pragma mark - public
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _collectionView.backgroundColor = backgroundColor;
}

- (void)reloadData{
    [_collectionView reloadData];
    [self p_numsOfCount];
}

- (void)setIsRecycle:(BOOL)isRecycle {
    _isRecycle = isRecycle;
    if (isRecycle) {
        [self addTimer];
    } else {
        [self p_timerStop];
    }
}

- (float)interval {
    return _interval < 1 ? kDefaultPageInterval : _interval;
}

#pragma mark - collection Delegate & datesource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld",(long)indexPath.row);
    CDPageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRecycleCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    cell.label.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    _lastContentOffsetX = collectionView.contentOffset.x;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self p_showCurrentPage];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self p_numsOfCount];
    return _totalCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _r_size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _r_minimumLineSpacing;
}

#pragma mark - scrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffSetX = scrollView.contentOffset.x;
    NSLog(@"%f",contentOffSetX);
    CGFloat width = [self referenceDelta];
    if (contentOffSetX <= 0) {
        scrollView.contentOffset = CGPointMake(width * _visiableCount + contentOffSetX, 0);
        return;
    }
    else if (contentOffSetX >= width * (_visiableCount + 1)) {
        scrollView.contentOffset = CGPointMake(width + (int)contentOffSetX % (int)width, 0);
        return;
    }
}

#pragma mark - gesture Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view];
        ///判断是否是左右滑动的
        if (fabs(translation.y) < fabs(translation.x)) {
            return YES;
        }
    }
    return NO;
}

- (void)dealloc {
    [self p_timerStop];
}

@end
