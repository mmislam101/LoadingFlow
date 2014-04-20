//
//  ArcLayer.h
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/17/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface LoadingFlowSectionView : UIView

@property (nonatomic, assign) CGFloat innerRadius;
@property (nonatomic, assign) CGFloat outerRadius;
@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, assign) NSTimeInterval animationDuration;

- (id)initWithFrame:(CGRect)frame innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius;

- (void)clearSections;

- (void)addSectionWithStartAngle:(CGFloat)startDegree endAngle:(CGFloat)endDegree andColor:(UIColor *)backgroundColor;
- (void)addLabel:(UILabel *)label toSection:(NSInteger)section atPosition:(CGFloat)percentage;
- (void)highlightSection:(NSInteger)section withColor:(UIColor *)color;

+ (CGPoint)pointOnCircleWithRadius:(CGFloat)radius andCenter:(CGPoint)center atDegree:(CGFloat)degree;

- (void)expandArcs;
- (void)retractArcs;

- (void)danceArc;

@end
