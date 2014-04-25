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

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
        return self;

	self.thicknessRatio = 0.0;

	return self;
}

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

	CGFloat thicknessRatio				= (-1.0/1100.0) * self.frame.size.width + (27.0/55.0); // Equation of a line where (100, 0.4) and (320, 0.2)
	CABasicAnimation *thinProgress		= [CABasicAnimation animationWithKeyPath:@"thicknessRatio"];
	thinProgress.fromValue				= [NSNumber numberWithFloat:self.thicknessRatio];
	thinProgress.toValue				= [NSNumber numberWithFloat:thicknessRatio];
	thinProgress.duration				= 0.5;

	self.thicknessRatio					= thicknessRatio;

	// Animation group
	CAAnimationGroup* group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:bounceProgress, thinProgress, nil];
	group.duration = duration;

	[self.layer addAnimation:group forKey:@"alskdf"];

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

	self.progress				= progress;
	[self.layer addAnimation:animation forKey:@"skipProgress"];

	[CATransaction commit];
}

@end
