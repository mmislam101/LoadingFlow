//
//  ArcLayer.m
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/17/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import "ArcViewFactory.h"

#define DEGREES_TO_RADIANS(degrees)	((M_PI * degrees) / 180.0)

@implementation ArcView

@end

@implementation ArcViewFactory

- (id)initWithFrame:(CGRect)frame innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outRadius
{
	if (!(self = [super init]))
        return self;

	self.frame				= frame;
	self.innerRadius		= innerRadius;
	self.outerRadius		= outRadius;

	self.center				= CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);

	return self;
}

- (ArcView *)arcWithStartAngle:(CGFloat)startDegree endDegree:(CGFloat)endDegree andColor:(UIColor *)backgroundColor
{
	// Add a transform of -180.0 to match the loading progress
	CGFloat startAngle		= startDegree - 180.0;
	CGFloat endAngle		= endDegree - 180.0;

	UIBezierPath *ringPath	= [UIBezierPath bezierPath];

	// Inner circle
	[ringPath addArcWithCenter:self.center
						radius:self.innerRadius
					startAngle:DEGREES_TO_RADIANS(startAngle)
					  endAngle:DEGREES_TO_RADIANS(endAngle)
					 clockwise:YES];

	// Outer circle
	[ringPath addArcWithCenter:self.center
						radius:self.outerRadius
					startAngle:DEGREES_TO_RADIANS(endAngle)
					  endAngle:DEGREES_TO_RADIANS(startAngle)
					 clockwise:NO];

	CAShapeLayer *arcLayer	= [CAShapeLayer layer];
	arcLayer.frame			= CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	arcLayer.path			= ringPath.CGPath;
	arcLayer.fillColor		= backgroundColor.CGColor;

	ArcView *arcView = [[ArcView alloc] initWithFrame:self.frame];
	[arcView.layer addSublayer:arcLayer];

	arcView.startDegree		= startDegree;
	arcView.endDegree		= endDegree;
	arcView.innerRadius		= self.innerRadius;
	arcView.outerRadius		= self.outerRadius;
	
	return arcView;
}

- (void)addLabel:(UILabel *)label toArcView:(ArcView *)arcView atPosition:(CGFloat)percentage
{
	CGSize labelSize	= [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
	label.frame			= CGRectMake(0.0,
									 0.0,
									 labelSize.width,
									 labelSize.height);

	CGFloat labelDegree	= ((arcView.endDegree - arcView.startDegree) * percentage) + arcView.startDegree;
	CGPoint point		= [self pointOnCircleWithRadius:((self.outerRadius - self.innerRadius) / 2.0) + self.innerRadius andCenter:self.center atDegree:labelDegree];
	label.center		= point;

	[arcView addSubview:label];
}

- (CGPoint)pointOnCircleWithRadius:(CGFloat)radius andCenter:(CGPoint)center atDegree:(CGFloat)degree
{
	// Add a transform of -180.0 to match the loading progress
	degree -= 180.0;
	return CGPointMake(center.x + (radius * cos(DEGREES_TO_RADIANS(degree))),
					   center.y + (radius * sin(DEGREES_TO_RADIANS(degree))));
}

@end
