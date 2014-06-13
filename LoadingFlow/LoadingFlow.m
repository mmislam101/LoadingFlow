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
	BOOL _hasStartedLoadingFlow;
	BOOL _displayingMessage;
	BOOL _isDismissingMessage;

	LoadingFlowSectionView *_arcView;
}

@property (nonatomic, strong) EasyTimeline *timeline;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) LoadingFlowSectionView *arcView;
@property (nonatomic, strong) LoadingProgressView *progressView;
@property (nonatomic, assign) BOOL displayingMessage;

@end

@implementation LoadingFlow

@synthesize
progressView			= _progressView,
currentSection			= _currentSection,
arcView					= _arcView,
timeline				= _timeline,
hasStartedLoadingFlow	= _hasStartedLoadingFlow,
displayingMessage		= _displayingMessage;

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
        return self;

	self.alpha				= 0.0;

	_sections				= [[NSMutableArray alloc] init];
	_currentSection			= 0;
	_timeline				= [[EasyTimeline alloc] init];
	_timeline.delegate		= self;
	_sideWidth				= ((frame.size.width < frame.size.height) ? frame.size.width : frame.size.height);
	_skipping				= NO;
	_waiting				= NO;
	_hasStartedLoadingFlow	= NO;
	_displayingMessage		= NO;
	_isDismissingMessage	= NO;
	_state					= LoadingFlowStateDismissed;

	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self addGestureRecognizer:tapGesture];

    return self;
}

- (void)initValues
{
	self.alpha							= 0.0;
	CGRect frame						= self.frame;
	_skipping							= NO;
	_currentSection						= 0;
	_hasStartedLoadingFlow				= NO;

	_progressView						= [[LoadingProgressView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
	_progressView.center				= CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
	_progressView.progress				= 0.0;
	_progressView.transform				= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90.0));
	_progressView.progressTintColor		= _tintColor;
	_progressView.trackTintColor		= [[UIColor blackColor] colorWithAlphaComponent:0.5];
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

	_arcView				= nil;
	_progressView			= nil;
	_waiting				= NO;
	_hasStartedLoadingFlow	= NO;
	_isDismissingMessage	= NO;
	_state					= LoadingFlowStateDismissed;

	[_timeline stop];
	[_timeline clear];

	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark Loading Flow Properties

- (void)addSection:(LoadingFlowSection *)section
{
	// Don't allow updating after the Loading Flow has started
	if (_hasStartedLoadingFlow)
		return;

	[_sections addObject:section];
}

- (void)removeSection:(LoadingFlowSection *)section
{
	// Don't allow updating after the Loading Flow has started
	if (_hasStartedLoadingFlow)
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

#pragma mark Loading Flow Control

- (void)startWithCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	if (_sections.count == 0 || _hasStartedLoadingFlow || _progressView.progress)
		return;

	[self destroyValues];
	[self initValues];

	_hasStartedLoadingFlow					= YES;
	_state									= LoadingFlowStateLoading;

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
	self.arcView.alpha					= 0.0;
	CGFloat progressViewSide			= _sideWidth * LOADING_FLOW_RING_SIZE;
	CGRect progressFrame				= CGRectMake(0.0, 0.0, progressViewSide, progressViewSide);
	[_progressView bounceToFillFrame:progressFrame duration:1.0 withCompletion:^{
		[weakSelf.arcView expandArcs];
		[UIView animateWithDuration:0.5 animations:^{
			weakSelf.arcView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[weakSelf startFirstSection];

			if (completion)
				completion(weakSelf);
		}];
	}];
}

- (void)displayMessageLabel:(UILabel *)label duration:(NSTimeInterval)duration withCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	if (_displayingMessage)
		return;

	_displayingMessage	= YES;

	if (_hasStartedLoadingFlow)
	{
		if (_timeline.hasStarted)
			[_timeline pause];
		else
		{
			// Animations are going on so this is the inbetween state where timeline hasn't started yet, so just invalidate it so when start is called, it won't do nothing.
			_timeline.duration = 0.0;
			[_arcView clear]; // Same for the arcview
		}

		// This allows the loading flow to start again.
		_hasStartedLoadingFlow = NO;
	}
	else
	{
		[self destroyValues];
		[self initValues];

		// Display the loading flow here
		self.alpha							= 1.0;
	}

	_state				= LoadingFlowStateMessage;

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

	[_progressView bounceToFillFrame:CGRectMake(0.0, 0.0, _sideWidth, _sideWidth) duration:2.0 withCompletion:nil];

	__weak LoadingFlow *weakSelf	= self;
	[UIView animateWithDuration:0.5
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
		weakSelf.arcView.alpha		= 0.0;
		messageView.alpha			= 1.0;
	} completion:^(BOOL finished) {
		// Using a delay on a normal UIView animation with delay causes the gesture recognizer to not function
		// even with the UIViewAnimationOptionAllowUserInteraction flag set on options
		// So did the delay this way
		if (duration > 0.0)
		{
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				[weakSelf dismissMessageWithCompletion:completion];
			});
		}
	}];
}

- (void)dismissMessageWithCompletion:(void (^)(LoadingFlow *loadingFlow))completion
{
	if (_isDismissingMessage)
		return;

	_isDismissingMessage = YES;

	__weak LoadingFlow *weakSelf	= self;
	[UIView animateWithDuration:0.5
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 weakSelf.alpha = 0.0;
					 } completion:^(BOOL finished) {
						 [weakSelf destroyValues];
						 weakSelf.displayingMessage = NO;

						 if (completion)
							 completion(weakSelf);
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
	
	if (!_hasStartedLoadingFlow)
	{
		if (completion)
			completion(weakSelf);
		return;
	}

	[UIView animateWithDuration:0.3 delay:0.0
						options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
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
	if (!_hasStartedLoadingFlow || _skipping || _currentSection >= _timeline.events.count || !_timeline.hasStarted)
		return;

	_skipping = YES;
	[_timeline pause];

	EasyTimelineEvent *currentEvent		= _timeline.events[_currentSection];
	LoadingFlowSection *currentSection	= _sections[_currentSection];
	currentSection.skipped				= YES;

	// Lower duration by ratio of remaining time in section
	duration							*= (currentEvent.time - _timeline.currentTime) / currentSection.duration;

	[_timeline skipForwardSeconds:currentEvent.time - _timeline.currentTime - 0.01];

	[_progressView skipProgressTo:currentEvent.time / _timeline.duration duration:duration withCompletion:^{
		[_timeline resume];
		_skipping = NO;
	}];
}

- (void)startWaitingWithSection:(LoadingFlowSection *)section
{
	if (_waiting)
		return;

	[self destroyValues];
	[self initValues];

	_waiting							= YES;
	_state								= LoadingFlowStateWait;

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
	NSInteger numberOfArcs				= section.duration;
	for (NSInteger i = 0; i < numberOfArcs; i++)
	{
		NSInteger startAngle = [self randomNumberBetween:0 and:360];
		[_arcView addSectionWithStartAngle:startAngle
								  endAngle:startAngle + 360.0
								  andColor:section.backgroundColor];
	}

	// Display the loading flow here
	_arcView.animationDuration			= 1.5;

	[_arcView danceArc];

	__weak LoadingFlow *weakSelf		= self;
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
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

	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
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

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
	if (_delegate && [_delegate respondsToSelector:@selector(loadingFlowWasTapped:)])
		[_delegate loadingFlowWasTapped:self];
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
