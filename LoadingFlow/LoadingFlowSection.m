//
//  LoadingFlowSection.m
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

#import "LoadingFlowSection.h"

@implementation LoadingFlowSection

+ (LoadingFlowSection *)sectionWithText:(NSString *)text andDuration:(NSTimeInterval)duration
{
	LoadingFlowSection *section		= [[LoadingFlowSection alloc] init];

	section.label					= [[UILabel alloc] initWithFrame:CGRectZero];
	section.label.backgroundColor	= [UIColor clearColor];
	section.label.text				= text;
	section.label.textColor			= [UIColor whiteColor];
	section.label.numberOfLines		= 0;

	section.backgroundColor			= [[UIColor blackColor] colorWithAlphaComponent:0.5];
	section.highlightColor			= [[UIColor blackColor] colorWithAlphaComponent:0.5];

	section.duration				= duration;
	section.skipped					= NO;
	section.labelPosition			= 0.5;

	return section;
}

@end
