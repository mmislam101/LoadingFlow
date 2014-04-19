//
//  LoadingProgressView.m
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/18/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import "LoadingProgressView.h"
#import "SKBounceAnimation.h"

@implementation LoadingProgressView

- (void)bounceFrom:(CGFloat)percentOfRadius
{
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	CGRect fromFrame					= CGRectMake(self.frame.size.width / 2.0 * percentOfRadius,
													 self.frame.size.height / 2.0 * percentOfRadius,
													 self.frame.size.width * percentOfRadius,
													 self.frame.size.height * percentOfRadius);
	bounceProgress.fromValue			= [NSValue valueWithCGRect:fromFrame];
	bounceProgress.toValue				= [NSValue valueWithCGRect:self.bounds];
	bounceProgress.duration				= 2.0f;
	bounceProgress.numberOfBounces		= 10;
	bounceProgress.shouldOvershoot		= YES;
	bounceProgress.shake				= YES;

	[self.layer addAnimation:bounceProgress forKey:@"bounceProgress"];
}

- (void)bounceToFillFrame:(CGRect)frame
{
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	bounceProgress.fromValue			= [NSValue valueWithCGRect:self.bounds];
	bounceProgress.toValue				= [NSValue valueWithCGRect:frame];
	bounceProgress.duration				= 3.0f;
	bounceProgress.numberOfBounces		= 5;
	bounceProgress.shouldOvershoot		= NO;
	bounceProgress.shake				= NO;

	self.bounds							= frame;

	[self.layer addAnimation:bounceProgress forKey:@"bounceProgress"];
}

- (void)skipProgressTo:(CGFloat)progress duration:(NSTimeInterval)duration withCompletion:(void (^)(void))completion
{
	[CATransaction begin];

	[CATransaction setCompletionBlock:^{
		completion();
	}];

	CABasicAnimation *animation	= [CABasicAnimation animationWithKeyPath:@"progress"];
	animation.duration			= duration;
	animation.timingFunction	= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.fromValue			= [NSNumber numberWithFloat:self.progress];
	animation.toValue			= [NSNumber numberWithFloat:progress];

	self.progress		= progress;
	[self.layer addAnimation:animation forKey:@"progress"];

	[CATransaction commit];
}

@end
