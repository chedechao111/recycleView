//
//  NSTimer+SafeTimer.h
//  CDCKit
//
//  Created by 车德超 on 2018/4/28.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (SafeTimer)

+ (NSTimer *)safe_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

@end
