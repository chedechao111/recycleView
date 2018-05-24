//
//  ViewController.m
//  CDRecycleView
//
//  Created by 车德超 on 2018/5/16.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import "ViewController.h"
#import "CDRecycleView.h"
#import "UIView+Additions.h"
#import "CDPageControl.h"
#import "CDPageView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface CDCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation CDCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _label = [UILabel new];
        _label.textColor = [UIColor blackColor];
        _label.frame = CGRectMake(0, 0, 100, 12);
        [self.contentView addSubview:_label];
    }
    return self;
}

@end

@interface ViewController ()<CDPageViewDelegate>

@end

@implementation ViewController
{
    CDPageControl *_pageControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CDPageView *recycle = [[CDPageView alloc] initWithFrame:CGRectMake(0, 100, 375, 200)];
    recycle.backgroundColor = [UIColor grayColor];
    recycle.r_size = CGSizeMake(375, recycle.height);
    recycle.r_minimumLineSpacing = 10;
    recycle.interval = 3;
    recycle.isRecycle = YES;
    recycle.delegate = self;
//    [recycle registerClass:[CDCell class] forCellWithReuseIdentifier:@"123"];
    [self.view addSubview:recycle];
    [recycle reloadData];
    
    _pageControl = [[CDPageControl alloc] init];
    _pageControl.isRightAlign = YES;
    _pageControl.backgroundColor = [UIColor redColor];
    _pageControl.frame = CGRectMake(0, recycle.bottom, self.view.width, 10);
    _pageControl.numberOfPages = 2;
    [self.view addSubview:_pageControl];
    
    
}


- (NSInteger)numberOfItems{
    return 2;
}

- (void)currentPageIndex:(NSUInteger)index{
    NSLog(@"%d",index);
    _pageControl.currentPage = index;
}


@end
