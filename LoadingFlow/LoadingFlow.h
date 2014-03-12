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
	CGFloat _sideWidth;
	NSMutableArray *_sections;
	DACircularProgressView *_progressView;

	EasyTimeline *_timeline;
	NSTimeInterval _tickFactor;

	NSTimeInterval _timeSinceStart;
	NSInteger _currentSection;

	UIColor *_ringBackgroundColor;

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

- (void)addSection:(LoadingFlowSection *)section;
- (void)removeSection:(LoadingFlowSection *)section;

#pragma mark Loading Flow State Property

@property (nonatomic, readonly) NSTimeInterval timeSinceStart;
@property (nonatomic, readonly) NSInteger currentSection;

#pragma mark Loading Flow Control

- (void)start;
- (void)pause;
- (void)stop;
- (void)nextSection;

- (void)displayMessage:(NSString *)string withDuration:(CGFloat)duration andCompletion:(void (^)(LoadingFlow *loadingFlow))completion; // This will stop the LoadingFlow, display the message for the duration and then fade out to completion

@end
