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
//	And my own EasyTimeline https://github.com/mmislam101/EasyTimeline

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"
#import "EasyTimeline.h"

@class LoadingFlow;
@class LoadingFlowSection;

@protocol LoadingFlowDelegate <NSObject>

@optional

- (void)loadingFlow:(LoadingFlow *)loadingFlow hasCompletedSection:(NSInteger)section;

@end

@interface LoadingFlow : UIView
{
	NSMutableArray *_sections;
	NSInteger _currentSection;

	EasyTimeline *_timeline;
}

@property (nonatomic, readonly) DACircularProgressView *progressView; // So that users have access to it

#pragma mark Loading Flow Properties

@property (nonatomic, assign) UIColor *tintColor;
@property (nonatomic, readonly) NSArray *sections;

- (void)addSection:(LoadingFlowSection *)section;
- (void)removeSection:(LoadingFlowSection *)section;

#pragma mark Loading Flow Control

- (void)start;
- (void)pause;
- (void)stop;
- (void)nextSection;
- (void)displayMessage:(NSString *)string withDuration:(CGFloat)duration andCompletion:(void (^)(LoadingFlow *loadingFlow))completion; // This will stop the LoadingFlow, display the message for the duration and then fade out to completion

@end
