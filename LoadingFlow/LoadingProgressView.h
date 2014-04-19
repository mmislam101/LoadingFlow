//
//  LoadingProgressView.h
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/18/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//
//	This class uses DACircularProgressView https://github.com/danielamitay/DACircularProgress

#import "DACircularProgressView.h"

@interface LoadingProgressView : DACircularProgressView

- (void)bounceFromStretched:(CGFloat)percentOfRadius duration:(NSTimeInterval)duration withCompletion:(void (^)(void))completion;
- (void)bounceToFillFrame:(CGRect)frame duration:(NSTimeInterval)duration withCompletion:(void (^)(void))completion;
- (void)skipProgressTo:(CGFloat)progress duration:(NSTimeInterval)duration withCompletion:(void (^)(void))completion;

@end
