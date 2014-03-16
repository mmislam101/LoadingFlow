//
//  LoadingFlow.h
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
//
//	This class uses DACircularProgressView https://github.com/danielamitay/DACircularProgress
//	As well as SKBounceAnimation https://github.com/khanlou/SKBounceAnimation
//	And my own EasyTimeline https://github.com/mmislam101/EasyTimeline

#import <UIKit/UIKit.h>
#import "LoadingFlowSection.h"
#import "DACircularProgressView.h"
#import "EasyTimeline.h"

@class LoadingFlow;

@protocol LoadingFlowDelegate <NSObject>

@optional

- (void)loadingFlow:(LoadingFlow *)loadingFlow hasCompletedSection:(LoadingFlowSection *)section atIndex:(NSInteger)idx;

@end

@interface LoadingFlow : UIView <EasyTimelineDelegate>
{
	UIView *_contentView;

	CGFloat _sideWidth;
	NSMutableArray *_sections;
	NSMutableArray *_sectionsMeta;
	DACircularProgressView *_progressView;

	EasyTimeline *_timeline;
	NSTimeInterval _tickFactor;

	NSTimeInterval _timeSinceStart;
	NSInteger _currentSection;

	__weak id <LoadingFlowDelegate> _delegate;

	CGFloat _innerRadius;
	CGFloat _outerRadius;
}

@property (weak, nonatomic) id <LoadingFlowDelegate> delegate;
@property (nonatomic, readonly) DACircularProgressView *progressView; // So that users have access to it

#pragma mark Loading Flow Properties

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, readonly) NSArray *sections;

#define LOADING_FLOW_RING_SIZE			0.33	// This determines size of loading ring
#define LOADING_FLOW_RING_GAP_RATIO		0.05	// This determines how large the gap between loading indicator and sections are
#define LOADING_FLOW_SECTION_GAP_RATIO	0.003	// This determines how large the gaps between sections are
#define LOADING_FLOW_SKIPPING_SPEED		1.0		// The speed at which sections will be skipped
#define LOADING_FLOW_MESSAGE_DURATION	2.0		// The duration at which displayMessage:withCompletion will

- (void)addSection:(LoadingFlowSection *)section;		// This doesn't work after Loading Flow has begun (paused or running)
- (void)removeSection:(LoadingFlowSection *)section;	// This doesn't work after Loading Flow has begun (paused or running)

#pragma mark Loading Flow State Property

@property (nonatomic, readonly) NSTimeInterval timeSinceStart;
@property (nonatomic, readonly) NSInteger currentSection;
@property (nonatomic, readonly) BOOL isRunning;

#pragma mark Loading Flow Control

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)skipToNextSection; // This will speed up the loading till it hits the next section. Can only be called once till skip finishes

// This will pause the LoadingFlow, display the message for LOADING_FLOW_MESSAGE_DURATION and then fade out to completion
- (void)displayMessageLabel:(UILabel *)label withCompletion:(void (^)(LoadingFlow *loadingFlow))completion;

@end
