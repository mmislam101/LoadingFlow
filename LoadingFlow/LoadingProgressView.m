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

- (void)bounceFromStretched:(CGFloat)percentOfRadius duration:(NSTimeInterval)duration withCompletion:(void (^)(void))completion
{
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	CGRect fromFrame					= CGRectMake(self.frame.size.width / 2.0 * percentOfRadius,
													 self.frame.size.height / 2.0 * percentOfRadius,
													 self.frame.size.width * percentOfRadius,
													 self.frame.size.height * percentOfRadius);
	bounceProgress.fromValue			= [NSValue valueWithCGRect:fromFrame];
	bounceProgress.toValue				= [NSValue valueWithCGRect:self.bounds];
	bounceProgress.duration				= duration;
	bounceProgress.numberOfBounces		= 7;
	bounceProgress.shake				= YES;

	[self.layer addAnimation:bounceProgress forKey:@"bounceFromStretched"];
}

- (void)bounceToFillFrame:(CGRect)frame duration:(NSTimeInterval)duration withCompletion:(void (^)(void))completion
{
	[CATransaction begin];

	[CATransaction setCompletionBlock:^{
		if (completion)
			completion();
	}];

	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	bounceProgress.fromValue			= [NSValue valueWithCGRect:self.bounds];
	bounceProgress.toValue				= [NSValue valueWithCGRect:frame];
	bounceProgress.duration				= duration;
	bounceProgress.numberOfBounces		= 3;
	bounceProgress.shake				= NO;

	self.bounds							= frame;

	[self.layer addAnimation:bounceProgress forKey:@"bounceToFill"];

	[CATransaction commit];
}

- (void)skipProgressTo:(CGFloat)progress duration:(NSTimeInterval)duration withCompletion:(void (^)(void))completion
{
	[CATransaction begin];

	[CATransaction setCompletionBlock:^{
		if (completion)
			completion();
	}];

	CABasicAnimation *animation	= [CABasicAnimation animationWithKeyPath:@"progress"];
	animation.duration			= duration;
	animation.timingFunction	= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.fromValue			= [NSNumber numberWithFloat:self.progress];
	animation.toValue			= [NSNumber numberWithFloat:progress];

	self.progress		= progress;
	[self.layer addAnimation:animation forKey:@"skipProgress"];

	[CATransaction commit];
}

@end
