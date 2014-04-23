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
#import "SKBounceAnimation.h"
#import "LoadingFlowSectionView.h"

#define DEGREES_TO_RADIANS(degrees)	((M_PI * degrees) / 180.0)

#define kSectionMetaStartAngle		@"kSectionMetaStartAngle"
#define kSectionMetaEndAngle		@"kSectionMetaEndAngle"

#define kRatioOfProgressToBounce	1.2

@interface LoadingFlow ()
{
	CGFloat _sideWidth;
	NSMutableArray *_sections;
	LoadingProgressView *_progressView;

	EasyTimeline *_timeline;
	NSTimeInterval _tickFactor;

	NSInteger _currentSection;

	__weak id <LoadingFlowDelegate> _delegate;

	CGFloat _innerRadius;
	CGFloat _outerRadius;
	BOOL _skipping;

	BOOL _waiting;

	LoadingFlowSectionView *_arcView;
}

@property (nonatomic, strong) EasyTimeline *timeline;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) LoadingFlowSectionView *arcView;
@property (nonatomic, strong) LoadingProgressView *progressView;

@end

@implementation LoadingFlow

@synthesize
progressView	= _progressView,
currentSection	= _currentSection,
arcView			= _arcView,
timeline		= _timeline;

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
        return self;

	self.alpha			= 0.0;

	_sections			= [[NSMutableArray alloc] init];
	_currentSection		= 0;
	_timeline			= [[EasyTimeline alloc] init];
	_timeline.delegate	= self;
	_sideWidth			= ((frame.size.width < frame.size.height) ? frame.size.width : frame.size.height);
	_skipping			= NO;
	_waiting			= NO;

    return self;
}

- (void)initValues
{
	self.alpha							= 0.0;
	CGRect frame						= self.frame;
	_skipping							= NO;
	_currentSection						= 0;

	_progressView						= [[LoadingProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
	_progressView.center				= CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
	_progressView.progress				= 0.0;
	_progressView.transform				= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90.0));
	_progressView.progressTintColor		= _tintColor;
	_progressView.thicknessRatio		= 0.4;

	[self addSubview:_progressView];

	_innerRadius						= (_sideWidth * LOADING_FLOW_RING_SIZE / 2.0) + (_sideWidth * LOADING_FLOW_RING_GAP_RATIO);
	_outerRadius						= _sideWidth / 2.0;

	_arcView							= [[LoadingFlowSectionView alloc] initWithFrame:self.bounds innerRadius:_innerRadius outerRadius:_outerRadius];

	[self addSubview:_arcView];
}

- (void)destroyValues
{
	[_arcView clear];
	[_arcView removeFromSuperview];
	[_progressView removeFromSuperview];

	_arcView		= nil;
	_progressView	= nil;
	_waiting		= NO;

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
	if (_sections.count == 0 || self.hasStarted || _progressView.progress)
		return;

	// TODO: user can start timer twice till timeline actually starts and the self.hasStarted finally starts returning true.
	// So need to disconnect hasStarted from timeline

	[self destroyValues];
	[self initValues];

	__block NSTimeInterval duration			= 0.0;
	__weak LoadingFlow *weakSelf			= self;
	[_sections enumerateObjectsUsingBlock:^(LoadingFlowSection *section, NSUInteger i, BOOL *stop) {
		duration += section.duration;
		[_timeline addEvent:[EasyTimelineEvent eventAtTime:duration withEventBlock:^(EasyTimelineEvent *event, EasyTimeline *timeline) {
			[weakSelf endOfSection:section];
		}]];
	}];

	if (duration <= 0.0)
		return;

	_tickFactor						= 1.0 / (duration * 100.0);

	_timeline.duration				= duration;
	_timeline.tickPeriod			= 0.01;

	// Setup Sections
	__block CGFloat degreeCursor	= 0.0;
	CGFloat sectionGap				= LOADING_FLOW_SECTION_GAP_RATIO * _sideWidth;
	[_sections enumerateObjectsUsingBlock:^(LoadingFlowSection *section, NSUInteger idx, BOOL *stop) {
		CGFloat endAngle	= 360.0 * (section.duration / _timeline.duration) + degreeCursor;

		[_arcView addSectionWithStartAngle:degreeCursor + sectionGap
									endAngle:endAngle - sectionGap
									 andColor:section.backgroundColor];

		[_arcView addLabel:section.label toSection:_arcView.numberOfSections-1 atPosition:section.labelPosition];

		degreeCursor = endAngle;
	}];

	// Display the loading flow here
	self.alpha							= 1.0;
	_progressView.trackTintColor		= [[UIColor blackColor] colorWithAlphaComponent:0.5]; // TODO: Remove this
	CGFloat progressViewSide			= _sideWidth * LOADING_FLOW_RING_SIZE;
	CGRect progressFrame				= CGRectMake(0.0, 0.0, progressViewSide, progressViewSide);
	[_progressView bounceToFillFrame:progressFrame duration:1.0 withCompletion:^{
		[weakSelf.arcView expandArcs];
		weakSelf.arcView.alpha = 1.0;
		[weakSelf startFirstSection];
	}];
}

- (void)pause
{
	[_timeline pause];
}

- (void)resume
{
	[_timeline resume];
}

- (void)stopWithCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	__weak LoadingFlow *weakSelf = self;
	
	if (!self.hasStarted)
	{
		if (completion)
			completion(weakSelf);
		return;
	}

	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		weakSelf.alpha = 0.0;
	} completion:^(BOOL finished) {
		[weakSelf destroyValues];
		if (completion)
			completion(weakSelf);
	}];
}

- (void)clear
{
	[self stopWithCompletion:nil];

	[self destroyValues];

	[_sections removeAllObjects];
}

- (void)skipToNextSectionWithDuration:(NSTimeInterval)duration
{
	// If hasn't started or is currently skipping
	if (!self.hasStarted || _skipping || _currentSection >= _timeline.events.count)
		return;

	_skipping = YES;
	[_timeline pause];

	EasyTimelineEvent *currentEvent		= _timeline.events[_currentSection];
	LoadingFlowSection *currentSection	= _sections[_currentSection];

	// Lower duration by ratio of remaining time in section
	duration							*= (currentEvent.time - _timeline.currentTime) / currentSection.duration;

	[_timeline skipForwardSeconds:currentEvent.time - _timeline.currentTime - 0.01];

	[_progressView skipProgressTo:currentEvent.time / _timeline.duration duration:duration withCompletion:^{
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
		CGPoint center			= CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
		CGPoint topLeftPoint	= [LoadingFlowSectionView pointOnCircleWithRadius:radius andCenter:center atDegree:45.0];
		CGPoint topRightPoint	= [LoadingFlowSectionView pointOnCircleWithRadius:radius andCenter:center atDegree:90.0 + 45.0];
		CGPoint bottomLeftPoint	= [LoadingFlowSectionView pointOnCircleWithRadius:radius andCenter:center atDegree:180.0 + 90.0 + 45.0];
		label.frame				= CGRectMake(topLeftPoint.x,
											 topLeftPoint.y,
											 topRightPoint.x - topLeftPoint.x,
											 bottomLeftPoint.y - topLeftPoint.y);

		[messageView addSubview:label];
	}

	[_arcView retractArcs];
	[_progressView bounceToFillFrame:CGRectMake(0.0, 0.0, _sideWidth, _sideWidth) duration:2.0 withCompletion:nil];

	__weak LoadingFlow *weakSelf	= self;
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		weakSelf.arcView.alpha		= 0.0;
		messageView.alpha			= 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 delay:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
			weakSelf.alpha = 0.0;
		} completion:^(BOOL finished) {
			[messageView removeFromSuperview];

			[weakSelf destroyValues];

			if (completion)
				completion(weakSelf);
		}];
	}];
}

- (void)startWaitingWithSection:(LoadingFlowSection *)section
{
	if (_waiting)
		return;

	[self destroyValues];
	[self initValues];

	_waiting							= YES;

	_arcView.innerRadius				= (_sideWidth / 2.0) * 0.4;

	// Add the label
	if (section.label)
	{
		CGPoint topLeftPoint	= [LoadingFlowSectionView pointOnCircleWithRadius:_arcView.innerRadius andCenter:_arcView.center atDegree:45.0];
		CGPoint topRightPoint	= [LoadingFlowSectionView pointOnCircleWithRadius:_arcView.innerRadius andCenter:_arcView.center atDegree:90.0 + 45.0];
		CGPoint bottomLeftPoint	= [LoadingFlowSectionView pointOnCircleWithRadius:_arcView.innerRadius andCenter:_arcView.center atDegree:180.0 + 90.0 + 45.0];
		section.label.frame		= CGRectMake(topLeftPoint.x,
											 topLeftPoint.y,
											 topRightPoint.x - topLeftPoint.x,
											 bottomLeftPoint.y - topLeftPoint.y);

		[_arcView addSubview:section.label];
	}

	// Get the section arcs ready
	NSInteger startAngle1				= [self randomNumberBetween:0 and:360];
	NSInteger startAngle2				= [self randomNumberBetween:0 and:360];
	[_arcView addSectionWithStartAngle:startAngle1
							  endAngle:startAngle1 + 360.0
							  andColor:section.backgroundColor];

	[_arcView addSectionWithStartAngle:startAngle2
							  endAngle:startAngle2 + 360.0
							  andColor:section.backgroundColor];

	// Display the loading flow here
	_arcView.animationDuration			= 1.5;

	[_arcView danceArc];

	__weak LoadingFlow *weakSelf		= self;
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		weakSelf.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)stopWaitingWithCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	__weak LoadingFlow *weakSelf = self;

	if (!_waiting)
	{
		if (completion)
			completion(weakSelf);
		return;
	}

	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		weakSelf.alpha = 0.0;
	} completion:^(BOOL finished) {
		[weakSelf destroyValues];
		if (completion)
			completion(weakSelf);
	}];
}

#pragma mark Loading States

- (void)startFirstSection
{
	[_timeline start];
}

#pragma mark Easy Timeline Delegates

- (void)endOfSection:(LoadingFlowSection *)section
{
	[_arcView highlightSection:[_sections indexOfObject:section] withColor:section.highlightColor];

	[_progressView bounceFromStretched:kRatioOfProgressToBounce duration:2.0 withCompletion:nil];

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

	[_arcView highlightSection:_sections.count-1 withColor:section.highlightColor];

	[_progressView bounceFromStretched:kRatioOfProgressToBounce duration:2.0 withCompletion:nil];

	[timeline stop];

	_progressView.progress = 1.0;

	if (_delegate && [_delegate respondsToSelector:@selector(loadingFlow:hasCompletedSection:atIndex:)])
		[_delegate loadingFlow:self hasCompletedSection:section atIndex:_currentSection];
}

- (NSInteger)randomNumberBetween:(NSInteger)min and:(NSInteger)max
{
	return min + arc4random() % (max - min + 1);
}

@end
