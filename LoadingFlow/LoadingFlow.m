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
#import "LoadingFlowSection.h"

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
	self.backgroundColor		= [[UIColor blackColor] colorWithAlphaComponent:0.75];
	self.layer.masksToBounds	= YES;
	
	_sections					= [[NSMutableArray alloc] init];
	_currentSection				= 0;
	_timeline					= [[EasyTimeline alloc] init];
	_timeline.delegate			= self;

	CGFloat progressViewSide	= (frame.size.width < frame.size.height) ? frame.size.width / 3.0 : frame.size.height / 3.0;
	CGRect progressFrame		= CGRectMake(0.0, 0.0, progressViewSide, progressViewSide);
	_progressView				= [[DACircularProgressView alloc] initWithFrame:progressFrame];
	_progressView.center		= CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
	_progressView.progress		= 0.0;

	[self addSubview:_progressView];

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

#pragma mark Loading Flow Control

- (void)start
{
	[self setupAndFadeIn];
}

- (void)pause
{

}

- (void)stop
{

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

	_tickFactor						= 1.0 / (duration * 100.0);

	_timeline.duration				= duration;
	_timeline.tickPeriod			= 0.01;

	__weak LoadingFlow *weakSelf	= self;
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

#pragma mark Easy Timeline Delegates

- (void)tickAt:(NSTimeInterval)time forTimeline:(EasyTimeline *)timeline
{
	_progressView.progress += _tickFactor;
}

- (void)finishedTimeLine:(EasyTimeline *)timeline
{
	_progressView.progress	= 1.0;
	[timeline stop];
}

@end
