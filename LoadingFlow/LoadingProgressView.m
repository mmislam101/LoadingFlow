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

	// Resize the bounds with bounce
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	bounceProgress.fromValue			= [NSValue valueWithCGRect:self.bounds];
	bounceProgress.toValue				= [NSValue valueWithCGRect:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)]; // Important that center doesn't change
	bounceProgress.duration				= duration;
	bounceProgress.numberOfBounces		= 5;
	bounceProgress.shake				= NO;

	self.bounds							= CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);

//	// Move the center
//	CGPoint newCenter					= CGPointMake(frame.origin.x + (frame.size.width / 2.0), frame.origin.y + (frame.size.height / 2.0));
//	CABasicAnimation *moveProgress		= [CABasicAnimation animationWithKeyPath:@"position"];
//	moveProgress.fromValue				= [NSValue valueWithCGPoint:self.center];
//	moveProgress.toValue				= [NSValue valueWithCGPoint:newCenter];
//	moveProgress.duration				= duration / 3.0;
//
//	self.center							= newCenter;

	// Resize the thickness
	CGFloat thicknessRatio				= (-1.0/1100.0) * frame.size.width + (27.0/55.0); // Equation of a line where (100, 0.4) and (320, 0.2)
	CABasicAnimation *thinProgress		= [CABasicAnimation animationWithKeyPath:@"thicknessRatio"];
	thinProgress.fromValue				= [NSNumber numberWithFloat:self.thicknessRatio];
	thinProgress.toValue				= [NSNumber numberWithFloat:thicknessRatio];
	thinProgress.duration				= duration / 4.0;

	self.thicknessRatio					= thicknessRatio;

	// Animation group
	CAAnimationGroup* group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:bounceProgress, /*moveProgress,*/ thinProgress, nil];
	group.duration = duration;

	[self.layer addAnimation:group forKey:@"bounceToFillProgress"];

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
