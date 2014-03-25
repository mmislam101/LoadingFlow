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

#define kSectionMetaStartAngle		@"kSectionMetaStartAngle"
#define kSectionMetaEndAngle		@"kSectionMetaEndAngle"

@interface LoadingFlow ()

@property (nonatomic, strong) EasyTimeline *timeline;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) NSMutableArray *sectionLayers;
@property (nonatomic, strong) DACircularProgressView *progressView;

@end

@implementation LoadingFlow

@synthesize
progressView	= _progressView,
currentSection	= _currentSection,
timeSinceStart	= _timeSinceStart,
contentView		= _contentView,
timeline		= _timeline,
sectionLayers	= _sectionLayers;

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
        return self;

	self.alpha							= 0.0;

	_sections							= [[NSMutableArray alloc] init];
	_sectionsMeta						= [[NSMutableArray alloc] init];
	_sectionLayers						= [[NSMutableArray alloc] init];
	_currentSection						= 0;
	_timeline							= [[EasyTimeline alloc] init];
	_timeline.delegate					= self;
	_sideWidth							= ((frame.size.width < frame.size.height) ? frame.size.width : frame.size.height);
	_skipping							= NO;

    return self;
}

- (void)initValues
{
	self.alpha							= 0.0;
	CGRect frame						= self.frame;
	_skipping							= NO;
	_currentSection						= 0;

	_contentView						= [[UIView alloc] initWithFrame:self.bounds];
	[self addSubview:_contentView];
	_contentView.layer.masksToBounds	= YES;

	CGFloat progressViewSide			= _sideWidth * LOADING_FLOW_RING_SIZE;
	CGRect progressFrame				= CGRectMake(0.0, 0.0, progressViewSide, progressViewSide);
	_progressView						= [[DACircularProgressView alloc] initWithFrame:progressFrame];
	_progressView.center				= CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
	_progressView.progress				= 0.0;
	_progressView.transform				= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90.0));
	_progressView.progressTintColor		= _tintColor;

	[self addSubview:_progressView];

	_innerRadius						= (_progressView.bounds.size.width / 2.0) + (_sideWidth * LOADING_FLOW_RING_GAP_RATIO);
	_outerRadius						= _sideWidth / 2.0;
}

- (void)destroyValues
{
	[_contentView removeFromSuperview];
	[_progressView removeFromSuperview];

	_contentView	= nil;
	_progressView	= nil;

	[_timeline stop];
	[_timeline clear];
}

#pragma mark Loading Flow Properties

- (void)addSection:(LoadingFlowSection *)section
{
	// Don't allow updating after the Loading Flow has started
	if (self.hasStarted)
		return;

	[_sections addObject:section];
}

- (void)removeSection:(LoadingFlowSection *)section
{
	// Don't allow updating after the Loading Flow has started
	if (self.hasStarted)
		return;

	[_sections removeObject:section];
}

- (void)setTintColor:(UIColor *)tintColor
{
	_tintColor						= tintColor;
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

- (BOOL)hasStarted
{
	return _timeline.hasStarted;
}

#pragma mark Loading Flow Control

- (void)start
{
	if (self.hasStarted || _progressView.progress)
		return;

	[self initValues];
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
	if (!self.hasStarted)
		return;

	__weak LoadingFlow *weakSelf = self;
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		weakSelf.alpha = 0.0;
	} completion:^(BOOL finished) {
		[weakSelf destroyValues];
	}];
}

- (void)skipToNextSection
{
	// If hasn't started or is currently skipping
	if (!self.hasStarted || _skipping || _currentSection >= _timeline.events.count)
		return;

	_skipping = YES;
	[_timeline pause];

	EasyTimelineEvent *currentEvent	= [_timeline.events objectAtIndex:_currentSection];
	[_timeline skipForwardSeconds:currentEvent.time - _timeline.currentTime - 0.01];

	[self skipProgressTo:currentEvent.time / _timeline.duration withCompletion:^{
		[_timeline resume];
		_skipping = NO;
		[_sections[_currentSection] setSkipped:YES];
	}];
}

- (void)displayMessageLabel:(UILabel *)label duration:(NSTimeInterval)duration withCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	[_timeline pause];

	UIView *messageView	= [[UIView alloc] initWithFrame:self.bounds];
	messageView.alpha	= 0.0;

	[self addSubview:messageView];

	if (label)
	{
		CGFloat radius			= _sideWidth / 2.0 - 50.0;
		CGPoint topLeftPoint	= [self pointOnCircleWithRadius:radius andCenter:_progressView.center atDegree:45.0];
		CGPoint topRightPoint	= [self pointOnCircleWithRadius:radius andCenter:_progressView.center atDegree:90.0 + 45.0];
		CGPoint bottomLeftPoint	= [self pointOnCircleWithRadius:radius andCenter:_progressView.center atDegree:180.0 + 90.0 + 45.0];
		label.frame				= CGRectMake(topLeftPoint.x,
											 topLeftPoint.y,
											 topRightPoint.x - topLeftPoint.x,
											 bottomLeftPoint.y - topLeftPoint.y);

		[messageView addSubview:label];
	}

	[self progressExpand];

	__weak LoadingFlow *weakSelf	= self;
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		weakSelf.contentView.alpha	= 0.0;
		messageView.alpha			= 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 delay:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
			weakSelf.alpha = 0.0;
		} completion:^(BOOL finished) {
			[messageView removeFromSuperview];

			[weakSelf destroyValues];
			
			completion(weakSelf);
		}];
	}];
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

	// Setup Sections
	__block CGFloat degreeCursor	= 0.0;
	CGFloat sectionGap				= LOADING_FLOW_SECTION_GAP_RATIO * _sideWidth;
	[_sections enumerateObjectsUsingBlock:^(LoadingFlowSection *section, NSUInteger idx, BOOL *stop) {
		CGFloat endAngle	= 360.0 * (section.duration / _timeline.duration) + degreeCursor;

		[_sectionsMeta addObject:@{kSectionMetaStartAngle : @(degreeCursor + sectionGap), kSectionMetaEndAngle : @(endAngle - sectionGap)}];

		CAShapeLayer *layer = [self ringLayerWithStartingDegree:degreeCursor + sectionGap endingDegree:endAngle - sectionGap andColor:section.backgroundColor];
		[_contentView.layer addSublayer:layer];
		[_sectionLayers addObject:layer];

		CGFloat labelDegree	= ((endAngle - degreeCursor) / 2.0) + degreeCursor;
		CGPoint point		= [self pointOnCircleWithRadius:((_outerRadius - _innerRadius) / 2.0) + _innerRadius andCenter:_progressView.center atDegree:labelDegree];
		[self addLabelForSection:section atPoint:point andDegree:labelDegree];

		degreeCursor = endAngle;
	}];

	// Start the Loading Flow going!
	[weakSelf startFirstSection];

	[UIView animateWithDuration:0.3 animations:^{
		weakSelf.alpha = 1.0;
	} completion:^(BOOL finished) {

	}];
}

- (void)startFirstSection
{
	[_timeline start];
}

#pragma mark Drawing functions

- (CAShapeLayer *)ringLayerWithStartingDegree:(CGFloat)startAngle endingDegree:(CGFloat)endAngle andColor:(UIColor *)color
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
	ringLayer.frame			= _contentView.bounds;
	ringLayer.path			= ringPath.CGPath;
	ringLayer.fillColor		= color.CGColor;

	return ringLayer;
}

- (void)addLabelForSection:(LoadingFlowSection *)section atPoint:(CGPoint)point andDegree:(CGFloat)degree
{
	CGSize labelSize		= [section.label.text sizeWithAttributes:@{NSFontAttributeName: section.label.font}];
	section.label.frame		= CGRectMake(0.0,
										 0.0,
										 labelSize.width,
										 labelSize.height);

	section.label.center	= point;

	[_contentView addSubview:section.label];
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

- (void)progressExpand
{
	CGRect finalRect					= CGRectMake(0.0,
													 0.0,
													 _sideWidth,
													 _sideWidth);
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	bounceProgress.fromValue			= [NSValue valueWithCGRect:_progressView.bounds];
	bounceProgress.toValue				= [NSValue valueWithCGRect:finalRect];
	bounceProgress.duration				= 3.0f;
	bounceProgress.numberOfBounces		= 5;
	bounceProgress.shouldOvershoot		= NO;
	bounceProgress.shake				= NO;

	_progressView.bounds				= finalRect;

	[_progressView.layer addAnimation:bounceProgress forKey:@"bounceProgress"];
}

- (void)progressRetract
{
	CGRect finalRect					= CGRectMake(0.0,
													 0.0,
													 _sideWidth,
													 _sideWidth);
	SKBounceAnimation *bounceProgress	= [SKBounceAnimation animationWithKeyPath:@"bounds"];
	bounceProgress.fromValue			= [NSValue valueWithCGRect:_progressView.bounds];
	bounceProgress.toValue				= [NSValue valueWithCGRect:finalRect];
	bounceProgress.duration				= 3.0f;
	bounceProgress.numberOfBounces		= 5;
	bounceProgress.shouldOvershoot		= NO;
	bounceProgress.shake				= NO;

	_progressView.bounds				= finalRect;

	[_progressView.layer addAnimation:bounceProgress forKey:@"bounceProgress"];
}

- (void)skipProgressTo:(CGFloat)progress withCompletion:(void (^)(void))completion
{
	[CATransaction begin];

	[CATransaction setCompletionBlock:^{
		completion();
	}];

	CABasicAnimation *animation	= [CABasicAnimation animationWithKeyPath:@"progress"];
	animation.duration			= LOADING_FLOW_SKIPPING_SPEED;
	animation.timingFunction	= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.fromValue			= [NSNumber numberWithFloat:_progressView.progress];
	animation.toValue			= [NSNumber numberWithFloat:progress];

	_progressView.progress		= progress;
	[_progressView.layer addAnimation:animation forKey:@"progress"];

	[CATransaction commit];
}

#pragma mark Easy Timeline Delegates

- (void)endOfSection:(LoadingFlowSection *)section
{
	NSDictionary *sectionMeta	= [_sectionsMeta objectAtIndex:[_sections indexOfObject:section]];

	CAShapeLayer *layer			= [self ringLayerWithStartingDegree:[sectionMeta[kSectionMetaStartAngle] floatValue] endingDegree:[sectionMeta[kSectionMetaEndAngle] floatValue] andColor:section.highlightColor];
	[_contentView.layer addSublayer:layer];
	[_sectionLayers addObject:layer];

	[self progressSmallBounce];

	if (_delegate && [_delegate respondsToSelector:@selector(loadingFlow:hasCompletedSection:atIndex:)])
		[_delegate loadingFlow:self hasCompletedSection:section atIndex:_currentSection];

	// For some reason sometimes the finishedTimeline doesn't fire if you skip within a 1.0 second event
	if (_currentSection ==  _sections.count - 1)
	{
		[_timeline stop];
		_progressView.progress = 1.0;
	}
	else
		_currentSection = [_sections indexOfObject:section] + 1;
}

- (void)tickAt:(NSTimeInterval)time forTimeline:(EasyTimeline *)timeline
{
	_progressView.progress = time / _timeline.duration;
}

- (void)finishedTimeLine:(EasyTimeline *)timeline
{
	LoadingFlowSection *section	= _sections[_sections.count-1];
	NSDictionary *sectionMeta	= [_sectionsMeta objectAtIndex:[_sections indexOfObject:section]];

	CAShapeLayer *layer			= [self ringLayerWithStartingDegree:[sectionMeta[kSectionMetaStartAngle] floatValue] endingDegree:[sectionMeta[kSectionMetaEndAngle] floatValue] andColor:section.highlightColor];
	[_contentView.layer addSublayer:layer];
	[_sectionLayers addObject:layer];

	[self progressSmallBounce];

	[timeline stop];

	_progressView.progress = 1.0;

	if (_delegate && [_delegate respondsToSelector:@selector(loadingFlow:hasCompletedSection:atIndex:)])
		[_delegate loadingFlow:self hasCompletedSection:section atIndex:_currentSection];
}

@end
