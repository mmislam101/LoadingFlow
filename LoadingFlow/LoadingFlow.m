//
//  LoadingFlow.m
//  TypeTeacher
//
//  Created by Mohammed Islam on 2/26/14.
//  Copyright (c) 2014 KSITechnology. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "LoadingFlow.h"
#import "DACircularProgressView.h"
#import "SKBounceAnimation.h"

#define DEGREES_TO_RADIANS(degrees)	((M_PI * degrees) / 180.0)

@implementation LoadingFlow

@synthesize
progressView	= _progressView,
currentSection	= _currentSection,
timeSinceStart	= _timeSinceStart;

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
        return self;

	self.alpha					= 0.0;
	self.layer.masksToBounds	= YES;
	
	_sections					= [[NSMutableArray alloc] init];
	_currentSection				= 0;
	_timeline					= [[EasyTimeline alloc] init];
	_timeline.delegate			= self;
	_sideWidth					= ((self.frame.size.width < self.frame.size.height) ? self.frame.size.width : self.frame.size.height);

	CGFloat progressViewSide	= ((frame.size.width < frame.size.height) ? frame.size.width : frame.size.height) * LOADING_FLOW_RING_SIZE;
	CGRect progressFrame		= CGRectMake(0.0, 0.0, progressViewSide, progressViewSide);
	_progressView				= [[DACircularProgressView alloc] initWithFrame:progressFrame];
	_progressView.center		= CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
	_progressView.progress		= 0.0;
	_progressView.transform		= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90.0));

	[self addSubview:_progressView];

	_innerRadius				= (_progressView.bounds.size.width / 2.0) + (_sideWidth * LOADING_FLOW_RING_GAP_RATIO);
	_outerRadius				= _sideWidth / 2.0;

    return self;
}

#pragma mark Loading Flow Properties

- (void)addSection:(LoadingFlowSection *)section
{
	[_sections addObject:section];
}

- (void)removeSection:(LoadingFlowSection *)section
{
	[_sections removeObject:section];
}

- (void)setTintColor:(UIColor *)tintColor
{
	_progressView.progressTintColor = tintColor;
}

#pragma mark Loading Flow State Property

- (NSTimeInterval)timeSinceStart
{
	return _progressView.progress / _tickFactor / 100.0;
}

- (BOOL)isRunning
{
	return _timeline.isRunning;
}

// Hijack the usual view's background color for the ring's color
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	self.backgroundColor	= [UIColor clearColor];
	_ringBackgroundColor	= backgroundColor;
}

#pragma mark Loading Flow Control

- (void)start
{
	if (_progressView.progress > 0.0)
	{
		[self stop];
		[self startFirstSection];

		return;
	}

	[self setupAndFadeIn];
}

- (void)pause
{
	[_timeline pause];
}

- (void)resume
{
	[_timeline resume];
}

- (void)stop
{
	_progressView.progress = 0.0;
	[_timeline stop];
}

- (void)nextSection
{

}

- (void)displayMessage:(NSString *)string withDuration:(CGFloat)duration andCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	
}

#pragma mark Loading States

- (void)setupAndFadeIn
{
	if (_sections.count == 0)
		return;

	__block NSTimeInterval duration = 0.0;
	[_sections enumerateObjectsUsingBlock:^(LoadingFlowSection *section, NSUInteger idx, BOOL *stop) {
		duration += section.duration;
	}];

	if (duration <= 0.0)
		return;

	__weak LoadingFlow *weakSelf			= self;
	__block NSTimeInterval sectionAlertTime	= 0.0;
	[_sections enumerateObjectsUsingBlock:^(LoadingFlowSection *section, NSUInteger i, BOOL *stop) {
		sectionAlertTime += section.duration;
		[_timeline addEvent:[EasyTimelineEvent eventAtTime:sectionAlertTime withEventBlock:^(EasyTimelineEvent *event, EasyTimeline *timeline) {
			[weakSelf endOfSection:section];
		}]];
	}];

	_tickFactor						= 1.0 / (duration * 100.0);

	_timeline.duration				= duration;
	_timeline.tickPeriod			= 0.01;

	[self setupSections];

	[UIView animateWithDuration:0.3 animations:^{
		weakSelf.alpha = 1.0;
	} completion:^(BOOL finished) {
		[weakSelf startFirstSection];
	}];
}

- (void)startFirstSection
{
	[_timeline start];
}

#pragma mark Drawing functions

- (void)setupSections
{
	__block CGFloat degreeCursor	= 0.0;
	CGFloat sectionGap				= LOADING_FLOW_SECTION_GAP_RATIO * _sideWidth;
	[_sections enumerateObjectsUsingBlock:^(LoadingFlowSection *section, NSUInteger idx, BOOL *stop) {
		CGFloat endAngle	= 360.0 * (section.duration / _timeline.duration) + degreeCursor;

		[self drawRingWithStartingDegree:degreeCursor + sectionGap endingDegree:endAngle - sectionGap];

		CGFloat labelDegree	= ((endAngle - degreeCursor) / 2.0) + degreeCursor;
		CGPoint point		= [self pointOnCircleWithRadius:((_outerRadius - _innerRadius) / 2.0) + _innerRadius andCenter:_progressView.center atDegree:labelDegree];
		[self addLabelForSection:section atPoint:point andDegree:labelDegree];

		degreeCursor += endAngle;
	}];
}

- (void)drawRingWithStartingDegree:(CGFloat)startAngle endingDegree:(CGFloat)endAngle
{
	// Add a transform of -180.0 to match the loading progress
	startAngle				-= 180.0;
	endAngle				-= 180.0;

	UIBezierPath *ringPath	= [UIBezierPath bezierPath];

	// Inner circle
	[ringPath addArcWithCenter:_progressView.center
						radius:_innerRadius
					startAngle:DEGREES_TO_RADIANS(startAngle)
					  endAngle:DEGREES_TO_RADIANS(endAngle)
					 clockwise:YES];

	// Outer circle
	[ringPath addArcWithCenter:_progressView.center
						radius:_outerRadius
					startAngle:DEGREES_TO_RADIANS(endAngle)
					  endAngle:DEGREES_TO_RADIANS(startAngle)
					 clockwise:NO];

	CAShapeLayer *ringLayer	= [CAShapeLayer layer];
	ringLayer.frame			= self.bounds;
	ringLayer.path			= ringPath.CGPath;
	ringLayer.fillColor		= [_sections[0] backgroundColor].CGColor;

	[self.layer addSublayer:ringLayer];
}

- (void)addLabelForSection:(LoadingFlowSection *)section atPoint:(CGPoint)point andDegree:(CGFloat)degree
{
	CGSize labelSize		= [section.label.text sizeWithAttributes:@{NSFontAttributeName: section.label.font}];
	section.label.frame		= CGRectMake(0.0,
										 0.0,
										 labelSize.width,
										 labelSize.height);

	section.label.center	= point;

	[self addSubview:section.label];
}

- (CGPoint)pointOnCircleWithRadius:(CGFloat)radius andCenter:(CGPoint)center atDegree:(CGFloat)degree
{
	// Add a transform of -180.0 to match the loading progress
	degree -= 180.0;
	return CGPointMake(center.x + (radius * cos(DEGREES_TO_RADIANS(degree))),
					   center.y + (radius * sin(DEGREES_TO_RADIANS(degree))));
}

- (void)progressBigBounce
{
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	bounceProgress.fromValue			= [NSValue valueWithCGRect:CGRectInset(_progressView.bounds, -(_sideWidth * LOADING_FLOW_RING_GAP_RATIO), -(_sideWidth * LOADING_FLOW_RING_GAP_RATIO))];
	bounceProgress.toValue				= [NSValue valueWithCGRect:_progressView.bounds];
	bounceProgress.duration				= 2.0f;
	bounceProgress.numberOfBounces		= 10;
	bounceProgress.shouldOvershoot		= YES;
	bounceProgress.shake				= YES;

	[_progressView.layer addAnimation:bounceProgress forKey:@"bounceProgress"];
}

- (void)progressSmallBounce
{
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	bounceProgress.fromValue			= [NSValue valueWithCGRect:CGRectInset(_progressView.bounds, -(_sideWidth * LOADING_FLOW_RING_GAP_RATIO / 3.0), -(_sideWidth * LOADING_FLOW_RING_GAP_RATIO / 3.0))];
	bounceProgress.toValue				= [NSValue valueWithCGRect:_progressView.bounds];
	bounceProgress.duration				= 2.0f;
	bounceProgress.numberOfBounces		= 10;
	bounceProgress.shouldOvershoot		= YES;
	bounceProgress.shake				= YES;

	[_progressView.layer addAnimation:bounceProgress forKey:@"bounceProgress"];
}

#pragma mark Easy Timeline Delegates

- (void)endOfSection:(LoadingFlowSection *)section
{
	[self progressSmallBounce];

	if (_delegate && [_delegate respondsToSelector:@selector(loadingFlow:hasCompletedSection:atIndex:)])
		[_delegate loadingFlow:self hasCompletedSection:section atIndex:[_sections indexOfObject:section]];
}

- (void)tickAt:(NSTimeInterval)time forTimeline:(EasyTimeline *)timeline
{
	_progressView.progress += _tickFactor;
}

- (void)finishedTimeLine:(EasyTimeline *)timeline
{
	[timeline stop];

	_progressView.progress = 1.0;
	[self progressBigBounce];

	if (_delegate && [_delegate respondsToSelector:@selector(loadingFlow:hasCompletedSection:atIndex:)])
		[_delegate loadingFlow:self hasCompletedSection:_sections[_sections.count-1] atIndex:_sections.count-1];
}

@end
