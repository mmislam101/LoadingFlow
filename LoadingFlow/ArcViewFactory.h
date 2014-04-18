//
//  ArcLayer.h
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/17/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface ArcView : UIView

@property (nonatomic, assign) CGFloat innerRadius;
@property (nonatomic, assign) CGFloat outerRadius;
@property (nonatomic, assign) CGFloat startDegree;
@property (nonatomic, assign) CGFloat endDegree;

@end

@interface ArcViewFactory : NSObject

@property (nonatomic, assign) CGFloat innerRadius;
@property (nonatomic, assign) CGFloat outerRadius;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGRect frame;

- (id)initWithFrame:(CGRect)frame innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outRadius;

- (ArcView *)arcWithStartAngle:(CGFloat)startDegree endDegree:(CGFloat)endDegree andColor:(UIColor *)backgroundColor;
- (void)addLabel:(UILabel *)label toArcView:(ArcView *)arcView atPosition:(CGFloat)percentage;
- (void)highlightArc:(ArcView *)view withColor:(UIColor *)color;

+ (CGPoint)pointOnCircleWithRadius:(CGFloat)radius andCenter:(CGPoint)center atDegree:(CGFloat)degree;

@end
