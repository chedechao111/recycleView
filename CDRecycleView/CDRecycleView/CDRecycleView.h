//
//  CDRecycleView.h
//  CDCKit
//
//  Created by 车德超 on 2018/4/26.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CDRecycleViewDelegate <NSObject>

@required
- (UIView *)recycleCell:(UICollectionViewCell *)recycleCell cellForItemAtIndex:(int)index;
- (NSInteger)numberOfItems;

@optional
- (void)clickEventIndex:(int)index;
- (void)currentPageIndex:(NSUInteger)index;

@end

@interface CDRecycleView : UIView

@property (nonatomic, assign) CGFloat r_minimumLineSpacing;
@property (nonatomic, assign) CGSize r_size;
@property (nonatomic, assign) UIEdgeInsets r_edge;
@property (nonatomic, assign) float interval;
@property (nonatomic, assign) BOOL isRecycle;
@property (nonatomic, weak) id<CDRecycleViewDelegate> delegate;

- (void)reloadData;
- (void)autoLayoutStartLocation;

@end
