//
//  UIView+Additions.h
//  ZDComponents
//
//  Created by zhuchao on 13-12-19.
//  Copyright (c) 2013年. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (UIImage *)captureView;

@end

typedef enum {
    UIViewBorderOptionTop = 0,
    UIViewBorderOptionRight,
    UIViewBorderOptionBottom,
    UIViewBorderOptionLeft,
    UIViewBorderOptionAll
}UIViewBorderOption;

@interface UIView (Border)

- (void) setBorder: (UIViewBorderOption)option  width:(CGFloat)width color: (UIColor *)color;
- (void) setDashBorder: (UIViewBorderOption)option  width:(CGFloat)width color: (UIColor *)color;
- (void) roundCornerWithDashBorder: (CGFloat)radius width: (CGFloat)widht color: (UIColor *)color;

@end


@interface UIView (FrameAdditions)
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float width;
@property (nonatomic) float height;
@property (nonatomic,getter = y,setter = setY:) float top;
@property (nonatomic,getter = x,setter = setX:) float left;
@property (nonatomic) float bottom;
@property (nonatomic) float right;
@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

// 设置最大右边
- (void)setMaxRight:(CGFloat)maxRight;
@end


@interface UIView(ScreenShot)

+ (UIImage *)screenShot;
+ (UIImage *)screenShotWithoutStatusBar;

- (UIImage *)screenShot;

@end



@interface UIView (TKCategory)

// DRAW GRADIENT
+ (void) drawGradientInRect:(CGRect)rect withColors:(NSArray*)colors;

// DRAW ROUNDED RECTANGLE
+ (void) drawRoundRectangleInRect:(CGRect)rect withRadius:(CGFloat)radius color:(UIColor*)color;

// DRAW LINE
+ (void) drawLineInRect:(CGRect)rect red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (void) drawLineInRect:(CGRect)rect colors:(CGFloat[])colors;
+ (void) drawLineInRect:(CGRect)rect colors:(CGFloat[])colors width:(CGFloat)lineWidth cap:(CGLineCap)cap;

@end


@interface UIView (Gesture)

- (UILongPressGestureRecognizer *)addLogPressGestureWithTarget:(id)target selecter:(SEL)aSelector;

@end

@interface UIView (FindFirstResponder)
- (UIView *)findViewThatIsFirstResponder;
@end

@interface UIView (InScreen)
- (BOOL)checkInCurrentScreenWithEdgeInsets:(UIEdgeInsets)edgeInsets;
- (BOOL)checkInScreenYWithPaddingTop:(CGFloat)paddingTop paddingToBottom:(CGFloat)paddingToBottom;
- (BOOL)checkInScreenXWithPaddingLeft:(CGFloat)paddingLeft paddingToRight:(CGFloat)paddingToRight;
@end

@interface UIView (NearestController)
- (UIViewController *)findNearestController;
@end



