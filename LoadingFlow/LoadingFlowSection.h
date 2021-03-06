//
//  LoadingFlowSection.h
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

#import <Foundation/Foundation.h>

@interface LoadingFlowSection : NSObject

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSTimeInterval duration; // For Wait, the Integer of this value determines the number of dancing arcs
@property (nonatomic, strong) UIColor *backgroundColor; // Default set to translucent black
@property (nonatomic, strong) UIColor *highlightColor; // Default to more translucent black
@property (nonatomic, assign) BOOL skipped; // Default to NO, this will be set to YES if this section was skipped
@property (nonatomic, assign) CGFloat labelPosition; // Default to 0.5, so halfway through a section

+ (LoadingFlowSection *)sectionWithText:(NSString *)text andDuration:(NSTimeInterval)duration;

@end
