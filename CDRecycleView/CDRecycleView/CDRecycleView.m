//
//  CDRecycleView.m
//  CDCKit
//
//  Created by 车德超 on 2018/4/26.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import "CDRecycleView.h"
#import "NSTimer+SafeTimer.h"
#import "UIView+Additions.h"

static NSString *const kRecycleCellIdentifier = @"RecycleCellIdentifier";
static int const kDefaultPageInterval = 2;

@interface CDRecycleView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
@end

@implementation CDRecycleView
{
    UICollectionView *_collectionView;
    UIPanGestureRecognizer *_pan;
    NSArray *_collectionResource;
    NSUInteger _totalCount;
    NSUInteger _visiableCount;
    NSUInteger _preVisiableCount;
    NSArray *_cellsX;
    CGFloat _lastTranslation;
    CGFloat _lastContentOffsetX;
    NSTimer *_timer;
    int p_currentPage;
    CGFloat _lastvelocity;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        p_currentPage = 0;
        [self createCollectionView];
        [self addPanGesture];
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
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kRecycleCellIdentifier];
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
    _timer = [NSTimer safe_scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(p_timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _collectionView.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _collectionView.backgroundColor = backgroundColor;
}

#pragma mark - private timer op
- (void)p_timerAction {
    [self p_rollToNextPage];
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

#pragma mark - private custom page's effect
- (void)p_panGestureAction {
    UIGestureRecognizerState state = _pan.state;
    CGFloat translationX = [_pan translationInView:self].x;
    CGFloat velocity = [_pan velocityInView:self].x;
    CGFloat contentOffsetX = _collectionView.contentOffset.x;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            [self p_timerPause];
            _lastTranslation = 0;
            _lastvelocity = 0;
            break;
        case UIGestureRecognizerStateChanged:{
            CGFloat incrementVelocity = velocity - _lastvelocity;
            CGFloat incrementTranslation = translationX - _lastTranslation;
            contentOffsetX -= incrementTranslation * MIN(MAX(fabs(incrementVelocity),self.size.width), 500) / self.size.width;
            if (contentOffsetX < _collectionView.contentSize.width + _collectionView.contentInset.right && contentOffsetX > 0 - _collectionView.contentInset.left) {
                [_collectionView setContentOffset:CGPointMake(contentOffsetX, _collectionView.contentOffset.y)];
            }
            _lastTranslation = translationX;
            _lastvelocity = velocity;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:{
            [self p_setPageScrollContentOffsetX];
            [self p_timerStart];
        }
            break;
        default:
            [self p_setPageScrollContentOffsetX];
            [self p_timerStart];
            break;
    }
}

#pragma - private SET PAGE WITH FINGURE
- (int)p_calculateCurrentPage {
    CGFloat referenceDelta = [self referenceDelta] - 2;
    int temp = _collectionView.contentOffset.x / referenceDelta;
    if (temp > _totalCount - 1) {
        temp = _totalCount - 1;
    }
    return temp;
}

- (void)p_setPageScrollContentOffsetX {
    CGFloat referenceDelta = [self referenceDelta];
    CGFloat contentOffsetX = _collectionView.contentOffset.x;
    CGFloat middelReferenceX = contentOffsetX + self.width * .5;
    CGFloat middelReferenceCellX = [_cellsX[p_currentPage] floatValue] + self.r_size.width * .5;
    BOOL isInScope = contentOffsetX >= self.width * .5 && contentOffsetX < _collectionView.contentSize.width - self.width;
    BOOL isLOR = [self p_isLeftOrRight];
    if (isInScope) {
        if (isLOR && middelReferenceX >= middelReferenceCellX) {
            p_currentPage ++;
        } else if (!isLOR && middelReferenceX < middelReferenceX) {
            p_currentPage --;
        }
    }
    [_collectionView setContentOffset:CGPointMake(p_currentPage * referenceDelta, _collectionView.contentOffset.y) animated:YES];
    [self p_showCurrentPageWithIndex:p_currentPage];
}

// yes left no right
- (BOOL)p_isLeftOrRight {
    BOOL isLOR;
    CGFloat contentOffsetX = _collectionView.contentOffset.x;
    if (contentOffsetX - _lastContentOffsetX > 0) {
        isLOR = YES;
    } else {
        isLOR = NO;
    }
    _lastContentOffsetX = _collectionView.contentOffset.x;
    return isLOR;
}

#pragma - private cell frame
- (void)p_storeCellsFrame {
    NSMutableArray *cellsX = [NSMutableArray array];
    CGFloat startLocation = _r_edge.left;
    CGFloat cellWidth = self.r_size.width;
    CGFloat delta = _r_minimumLineSpacing;
    CGFloat nextCellX;
    for (NSInteger i = 0; i < _totalCount; i++) {
        nextCellX = i * (cellWidth + delta) + startLocation;
        [cellsX addObject:@(nextCellX)];
    }
    _cellsX = [cellsX copy];
}

#pragma - private recycle op
- (CGFloat)referenceDelta {
    return self.r_size.width + _r_minimumLineSpacing;
}

- (CGFloat)p_startLoaction {
    return [self referenceDelta];
}

- (CGFloat)p_endLoaction {
    return (_visiableCount + 1) * [self referenceDelta];
}

- (void)p_setRollToStart {
    CGFloat start = [self p_startLoaction];
    [_collectionView setContentOffset:CGPointMake(start, _collectionView.contentOffset.y)];
}

- (void)p_setRollToLast {
    CGFloat end = [self p_endLoaction];
    [_collectionView setContentOffset:CGPointMake(end, _collectionView.contentOffset.y)];
}

- (void)p_checkStartContentOffset {
    CGFloat start = [self p_startLoaction];
    if (_collectionView.contentOffset.x < start) {
        [self p_setRollToLast];
    }
}

- (void)p_checkEndContentOffset {
    CGFloat end = [self p_endLoaction];
    if (_collectionView.contentOffset.x > end) {
        [self p_setRollToStart];
    }
}

- (void)p_rollToNextPage {
    int temp = p_currentPage;
    if (temp == _totalCount - 1) {
        temp = 1;
    }
    [_collectionView setContentOffset:CGPointMake([self referenceDelta] * ++temp, _collectionView.contentOffset.y) animated:YES];
    p_currentPage = temp;
    [self p_showCurrentPageWithIndex:p_currentPage];
}

- (void)p_showCurrentPageWithIndex:(int)index {
    int temp = index;
    //两张轮播特殊处理
    if(temp == 4 && _visiableCount == 2) {
        temp = 1;
    } else{
        if (temp > _visiableCount) {
            temp = temp % (_visiableCount);
        }
        temp = _isRecycle ? MAX(temp - 1, 0) : temp;
    }
    if ([_delegate respondsToSelector:@selector(currentPageIndex:)]) {
        [_delegate currentPageIndex:temp];
    }
}

- (void)p_NumsOfItem {
    _visiableCount = [_delegate numberOfItems];
    if (_preVisiableCount != _visiableCount) {
        _totalCount = _isRecycle ? _visiableCount + 3 : _visiableCount;
        [self p_storeCellsFrame];
    }
    _preVisiableCount = _visiableCount;
}

- (int)p_cellIndex:(NSUInteger)index {
    int temp = 0;
    if (_isRecycle) {
        temp = (int)index - 1;
        temp = temp < 0 ? 0 : temp;
        temp = temp > _visiableCount - 1 ? ABS(temp -= _visiableCount) : temp;
    } else {
        temp = (int)index;
    }
    return temp;
}

#pragma mark - public interface
- (void)reloadData {
    [_collectionView reloadData];
    [self scrollViewDidScroll:_collectionView];
    [self p_NumsOfItem];
}

- (void)setIsRecycle:(BOOL)isRecycle {
    _isRecycle = isRecycle;
    if (isRecycle) {
        [self addTimer];
    } else {
        [self p_timerStop];
    }
}

- (CGSize)r_size {
    if (CGSizeEqualToSize(_r_size, CGSizeZero)) {
        _r_size = self.size;
    }
    return _r_size;
}

- (float)interval {
    return _interval < 1 ? kDefaultPageInterval : _interval;
}

- (void)autoLayoutStartLocation {
    if (UIEdgeInsetsEqualToEdgeInsets(_r_edge, UIEdgeInsetsZero)) {
        CGFloat sidesMargin = (self.width - self.r_size.width) * .5;
        UIEdgeInsets edgeInset = UIEdgeInsetsMake(0, sidesMargin, 0, sidesMargin);
        [self setR_edge:edgeInset];
    }
}

#pragma mark - collection delegate & datasource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *recycleCell = [collectionView dequeueReusableCellWithReuseIdentifier:kRecycleCellIdentifier forIndexPath:indexPath];
    int index = [self p_cellIndex:indexPath.row];
    UIView *view = [_delegate recycleCell:recycleCell cellForItemAtIndex:index];
    [recycleCell addSubview:view];
    recycleCell.clipsToBounds = YES;
    return recycleCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int index = [self p_cellIndex:indexPath.row];
    if ([_delegate respondsToSelector:@selector(clickEventIndex:)]) {
        [_delegate clickEventIndex:index];
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self p_NumsOfItem];
    return _totalCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.r_size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.r_edge;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.r_minimumLineSpacing;
}


#pragma mark - scrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self p_timerPause];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isRecycle) {
        [self p_checkStartContentOffset];
        [self p_checkEndContentOffset];
    }
    p_currentPage = [self p_calculateCurrentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self p_setPageScrollContentOffsetX];
    [self p_timerStart];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self p_setPageScrollContentOffsetX];
        [self p_timerStart];
    }
}

#pragma mark - gesture delegate
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


#pragma mark - dealloc

- (void)dealloc {
    [self p_timerStop];
}

@end
