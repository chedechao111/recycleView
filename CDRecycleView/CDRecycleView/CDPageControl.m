//
//  WMHomePageControl.m
//  WMHomeModule
//
//  Created by 车德超 on 2018/5/3.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import "CDPageControl.h"
#import "UIView+Additions.h"

static int const kDotTag = 0x200;
static int const kDotWidth = 4;
static int const kDotSelectHeight = 6;

@implementation CDPageControl
{
    NSArray *_pageViewsArray;
    NSUInteger _preCurrentPage;
    CGRect _preFrame;
    CGFloat _pageMargin;
}

- (instancetype)init {
    if (self = [super init]) {
        _pageMargin = 5;
    }
    return self;
}

#pragma mark - public
- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    
    if (numberOfPages <= 1) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    if (_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        NSUInteger i = 0;
        NSMutableArray *pageTempArr = [NSMutableArray array];
        for (; i < numberOfPages; i++) {
            NSUInteger tag = i + kDotTag;
            UIView *dotView = [self p_createDotViewWithTag:tag];
            dotView.hidden = NO;
            [pageTempArr addObject:dotView];
        }
        [self p_hidelessViewWithIndex:i];
        _pageViewsArray = [pageTempArr copy];
        [self p_setPageFrame];
    }
}

- (void)setPageMargin:(CGFloat)pageMargin {
    _pageMargin = pageMargin;
    [self p_setPageFrame];
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    _currentPage = currentPage;
    if (_pageViewsArray.count <= 0) return;
    if (_currentPage > _pageViewsArray.count - 1) _currentPage = 0;
    [self p_setCurrentPageFrameWithCurrentIndex:_currentPage];
    _preCurrentPage = _currentPage;
}

- (void)setIsRightAlign:(BOOL)isRightAlign {
    _isRightAlign = isRightAlign;
    [self p_setPageFrame];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (!CGRectEqualToRect(frame, _preFrame)) {
        [self p_setPageFrame];
    }
    _preFrame = frame;
}

#pragma mark - private
- (void)p_setPageFrame {
    if (!(_pageViewsArray.count > 0 && _pageMargin > 0)) {
        return;
    }
    if (_isRightAlign) {
        [self p_setRightAlignFrame];
    } else {
        [self p_setLeftAlignFrame];
    }

    [self setCurrentPage:_preCurrentPage];
}

- (void)p_setRightAlignFrame {
    [self p_setLeftAlignFrame];
    UIView *lastView = _pageViewsArray[_pageViewsArray.count - 1];
    CGFloat delta = self.width - lastView.right;
    if (delta > 0) {
        for (UIView *view in _pageViewsArray) {
            view.x += delta;
        }
    }
}

- (void)p_setLeftAlignFrame {
    NSUInteger i = 0;
    CGFloat delta = kDotWidth + _pageMargin;
    for (UIView *view in _pageViewsArray) {
        CGFloat x = i * delta;
        view.frame = CGRectMake(x, 0, kDotWidth, kDotWidth);
        i++;
    }
}

- (UIView *)p_createDotViewWithTag:(NSUInteger)tag {
    UIView *dotView = [self viewWithTag:tag];
    if (!dotView) {
        dotView = [[UIView alloc] init];
        dotView.tag = tag;
        dotView.backgroundColor = [UIColor greenColor];
        dotView.layer.cornerRadius = 2;
        dotView.layer.shouldRasterize = YES;
        dotView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:dotView];
    }
    return dotView;
}

- (void)p_setCurrentPageFrameWithCurrentIndex:(NSUInteger)index {
    for (UIView *view in _pageViewsArray) {
        [UIView animateWithDuration:0.25 animations:^{
            if (view.tag == index + kDotTag) {
                view.backgroundColor = [UIColor yellowColor];
                view.y = -2;
                view.height = kDotSelectHeight;
            } else {
                view.y = 0;
                view.height = kDotWidth;
                view.backgroundColor = [UIColor greenColor];
            }
        }];
    }
}

- (void)p_hidelessViewWithIndex:(NSUInteger)index {
    NSUInteger tag = index + kDotTag;
    while (true) {
        UIView *view = [self viewWithTag:tag];
        if (view) {
            if (!view.hidden) {
                view.hidden = YES;
            }
            tag++;
        } else {
            break;
        }
    }
}

@end
