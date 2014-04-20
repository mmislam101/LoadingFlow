//
//  ArcLayer.h
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/19/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface LoadingArcLayer : CALayer

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat innerRadius;
@property (nonatomic, assign) CGFloat outerRadius;
@property (nonatomic, assign) NSTimeInterval animationDuration;

// TODO: Find a better way than this
@property (nonatomic, assign) CGFloat startDegree;
@property (nonatomic, assign) CGFloat endDegree;

// Animatable properties
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;

- (void)startDancingWithDelay:(NSTimeInterval)delay;

@end
