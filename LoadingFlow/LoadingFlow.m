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
#import "ArcViewFactory.h"

#define DEGREES_TO_RADIANS(degrees)	((M_PI * degrees) / 180.0)

#define kSectionMetaStartAngle		@"kSectionMetaStartAngle"
#define kSectionMetaEndAngle		@"kSectionMetaEndAngle"

#define kRatioOfProgressToBounce	1.2

@interface LoadingFlow ()
{
	UIView *_contentView;

	CGFloat _sideWidth;
	NSMutableArray *_sections;
	NSMutableArray *_arcViews;
	LoadingProgressView *_progressView;

	EasyTimeline *_timeline;
	NSTimeInterval _tickFactor;

	NSInteger _currentSection;

	__weak id <LoadingFlowDelegate> _delegate;

	CGFloat _innerRadius;
	CGFloat _outerRadius;
	BOOL _skipping;

	BOOL _waiting;

	ArcViewFactory *_arcLayerFactory;
}

@property (nonatomic, strong) EasyTimeline *timeline;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) NSMutableArray *arcViews;
@property (nonatomic, strong) LoadingProgressView *progressView;

@end

@implementation LoadingFlow

@synthesize
progressView	= _progressView,
currentSection	= _currentSection,
contentView		= _contentView,
timeline		= _timeline,
arcViews		= _arcViews;

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
        return self;

	self.alpha			= 0.0;

	_sections			= [[NSMutableArray alloc] init];
	_arcViews			= [[NSMutableArray alloc] init];
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

	_contentView						= [[UIView alloc] initWithFrame:self.bounds];
	[self addSubview:_contentView];
	_contentView.layer.masksToBounds	= YES;

	_progressView						= [[LoadingProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
	_progressView.center				= CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
	_progressView.progress				= 0.0;
	_progressView.transform				= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90.0));
	_progressView.progressTintColor		= _tintColor;

	[self addSubview:_progressView];

	_innerRadius						= (_sideWidth * LOADING_FLOW_RING_SIZE / 2.0) + (_sideWidth * LOADING_FLOW_RING_GAP_RATIO);
	_outerRadius						= _sideWidth / 2.0;

	_arcLayerFactory					= [[ArcViewFactory alloc] initWithFrame:self.bounds
																	innerRadius:_innerRadius
																	outerRadius:_outerRadius];
}

- (void)destroyValues
{
	[_contentView removeFromSuperview];
	[_progressView removeFromSuperview];

	_contentView	= nil;
	_progressView	= nil;

	[_timeline stop];
	[_timeline clear];

	[_arcViews removeAllObjects];
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

	[self destroyValues];
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

	EasyTimelineEvent *currentEvent	= [_timeline.events objectAtIndex:_currentSection];
	[_timeline skipForwardSeconds:currentEvent.time - _timeline.currentTime - 0.01];

	// TODO: Treat duration as if it's from the beginning of the section to the end, so account for time remaining in section
//	NSLog(@"section duration: %f", [_sections[_currentSection] duration]);
//	NSLog(@"remaining duration: %f", self.timeSinceStart); // TODO: Need to find remaining time in section
//	duration = duration * (currentEvent.time - _timeline.currentTime / [_sections[_currentSection] duration]);

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
		CGPoint topLeftPoint	= [ArcViewFactory pointOnCircleWithRadius:radius andCenter:center atDegree:45.0];
		CGPoint topRightPoint	= [ArcViewFactory pointOnCircleWithRadius:radius andCenter:center atDegree:90.0 + 45.0];
		CGPoint bottomLeftPoint	= [ArcViewFactory pointOnCircleWithRadius:radius andCenter:center atDegree:180.0 + 90.0 + 45.0];
		label.frame				= CGRectMake(topLeftPoint.x,
											 topLeftPoint.y,
											 topRightPoint.x - topLeftPoint.x,
											 bottomLeftPoint.y - topLeftPoint.y);

		[messageView addSubview:label];
	}

	[_progressView bounceToFillFrame:CGRectMake(0.0, 0.0, _sideWidth, _sideWidth) duration:2.0 withCompletion:nil];

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

			if (completion)
				completion(weakSelf);
		}];
	}];
}

- (void)startWaitingWith:(LoadingFlowSection *)section
{
	if (_waiting)
		return;

	_waiting = YES;
}

- (void)stopWaitingWithCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	if (!_waiting)
	{
		__weak LoadingFlow *weakSelf = self;
		if (completion)
			completion(weakSelf);
		return;
	}

	_waiting = NO;
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
	ArcViewFactory *arcLayerFactory = [[ArcViewFactory alloc] initWithFrame:self.bounds
																  innerRadius:_innerRadius
																  outerRadius:_outerRadius];
	__block CGFloat degreeCursor	= 0.0;
	CGFloat sectionGap				= LOADING_FLOW_SECTION_GAP_RATIO * _sideWidth;
	[_sections enumerateObjectsUsingBlock:^(LoadingFlowSection *section, NSUInteger idx, BOOL *stop) {
		CGFloat endAngle	= 360.0 * (section.duration / _timeline.duration) + degreeCursor;

		ArcView *arc = [arcLayerFactory arcWithStartAngle:degreeCursor + sectionGap
													   endDegree:endAngle - sectionGap
														andColor:section.backgroundColor];

		[arcLayerFactory addLabel:section.label toArcView:arc atPosition:section.labelPosition];
		[_contentView addSubview:arc];
		[_arcViews addObject:arc];

		degreeCursor = endAngle;
	}];

	self.alpha							= 1.0;
	_progressView.trackTintColor		= [[UIColor blackColor] colorWithAlphaComponent:0.5]; // TODO: Remove this
	CGFloat progressViewSide			= _sideWidth * LOADING_FLOW_RING_SIZE;
	CGRect progressFrame				= CGRectMake(0.0, 0.0, progressViewSide, progressViewSide);
	[_progressView bounceToFillFrame:progressFrame duration:1.0 withCompletion:^{
		[weakSelf startFirstSection];
	}];
}

- (void)startFirstSection
{
	[_timeline start];
}

#pragma mark Easy Timeline Delegates

- (void)endOfSection:(LoadingFlowSection *)section
{
	[_arcLayerFactory highlightArc:_arcViews[[_sections indexOfObject:section]] withColor:section.highlightColor];

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

	[_arcLayerFactory highlightArc:_arcViews[[_sections indexOfObject:section]] withColor:section.highlightColor];

	[_progressView bounceFromStretched:kRatioOfProgressToBounce duration:2.0 withCompletion:nil];

	[timeline stop];

	_progressView.progress = 1.0;

	if (_delegate && [_delegate respondsToSelector:@selector(loadingFlow:hasCompletedSection:atIndex:)])
		[_delegate loadingFlow:self hasCompletedSection:section atIndex:_currentSection];
}

@end
