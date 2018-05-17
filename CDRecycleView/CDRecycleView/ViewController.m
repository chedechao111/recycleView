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

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<CDRecycleViewDelegate>

@end

@implementation ViewController
{
    CDPageControl *_pageControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CDRecycleView *recycle = [[CDRecycleView alloc] initWithFrame:CGRectMake(0, 100, 375, 200)];
    recycle.backgroundColor = [UIColor grayColor];
    recycle.r_size = CGSizeMake(320, recycle.height);
    recycle.r_minimumLineSpacing = 10;
    recycle.interval = 3;
    recycle.isRecycle = YES;
    recycle.delegate = self;
    [recycle autoLayoutStartLocation];
    [self.view addSubview:recycle];
    [recycle reloadData];
    
    _pageControl = [[CDPageControl alloc] init];
    _pageControl.isRightAlign = YES;
    _pageControl.backgroundColor = [UIColor redColor];
    _pageControl.frame = CGRectMake(0, recycle.bottom, self.view.width, 10);
    _pageControl.numberOfPages = 9;
    [self.view addSubview:_pageControl];
    
    
}

-(UIView *)recycleCell:(UICollectionViewCell *)recycleCell cellForItemAtIndex:(int)index{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    view.backgroundColor = [UIColor blueColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%d",index];
    [view addSubview:label];
    [label sizeToFit];
    return view;
}

- (NSInteger)numberOfItems{
    return 9;
}

- (void)currentPageIndex:(NSUInteger)index{
    NSLog(@"%d",index);
    _pageControl.currentPage = index;
}


@end
