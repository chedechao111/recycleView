//
//  CDPageView.h
//  CDRecycleView
//
//  Created by 车德超 on 2018/5/22.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CDPageViewDelegate <NSObject>

@required
//index 和 indexPath.row不一样，一个是索引，另一个是展示的顺序
- (__kindof UICollectionViewCell *)cellForItemAtIndex:(int)index displayIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)view;
- (NSInteger)numberOfItems;

@optional
- (void)clickEventIndex:(int)index;
- (void)currentPageIndex:(NSUInteger)index;

@end

@interface CDPageView : UIView

@property (nonatomic, assign) CGFloat r_minimumLineSpacing;
@property (nonatomic, assign) CGSize r_size;
@property (nonatomic, assign) float interval;
@property (nonatomic, assign) BOOL isRecycle;
@property (nonatomic, weak) id<CDPageViewDelegate> delegate;

- (void)reloadData;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

@end
