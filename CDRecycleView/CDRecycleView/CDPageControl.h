//
//  WMHomePageControl.h
//  WMHomeModule
//
//  Created by 车德超 on 2018/5/3.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDPageControl : UIView

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) CGFloat pageMargin;
@property (nonatomic, assign) BOOL isRightAlign;

@end
