//
//  NSTimer+SafeTimer.m
//  CDCKit
//
//  Created by 车德超 on 2018/4/28.
//  Copyright © 2018年 车德超. All rights reserved.
//

#import "NSTimer+SafeTimer.h"

@interface CDTimerProxy : NSProxy
@property (nonatomic, weak) id objc;
@end

@implementation CDTimerProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_objc methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:_objc];
}

@end

@implementation NSTimer (SafeTimer)

+ (NSTimer *)safe_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    CDTimerProxy *proxy = [CDTimerProxy alloc];
    proxy.objc = aTarget;
    return [self scheduledTimerWithTimeInterval:ti target:proxy selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

@end
