//
//  ArcLayer.m
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/17/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import "LoadingFlowSectionView.h"
#import "ArcLayer.h"

#define DEGREES_TO_RADIANS(degrees)	((M_PI * degrees) / 180.0)

@interface LoadingFlowSectionView ()
{
	NSMutableArray *_arcLayers;
}

@end

@implementation LoadingFlowSectionView

- (id)initWithFrame:(CGRect)frame innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outRadius
{
	if (!(self = [super initWithFrame:frame]))
        return self;

	self.innerRadius	= innerRadius;
	self.outerRadius	= outRadius;
	_arcLayers			= [[NSMutableArray alloc] init];

	return self;
}

- (void)clearSections
{
	[_arcLayers enumerateObjectsUsingBlock:^(ArcLayer *layer, NSUInteger idx, BOOL *stop) {
		[layer removeFromSuperlayer];
	}];

	[_arcLayers removeAllObjects];
}

- (NSInteger)numberOfSections
{
	return _arcLayers.count;
}

- (void)addSectionArcWithStartAngle:(CGFloat)startDegree endDegree:(CGFloat)endDegree andColor:(UIColor *)backgroundColor
{
	// Add a transform of -180.0 to match the loading progress
	CGFloat startAngle		= startDegree - 180.0;

	ArcLayer *arcLayer		= [ArcLayer layer];
	arcLayer.frame			= self.bounds;
	arcLayer.fillColor		= backgroundColor;

	arcLayer.startDegree	= startDegree;
	arcLayer.endDegree		= endDegree;
	arcLayer.startAngle		= startAngle;
	arcLayer.endAngle		= startAngle;
	arcLayer.innerRadius	= self.innerRadius;

	[self.layer addSublayer:arcLayer];

	[_arcLayers addObject:arcLayer];
}

- (void)addLabel:(UILabel *)label toSection:(NSInteger)section atPosition:(CGFloat)percentage
{
	ArcLayer *layer		= _arcLayers[section];
	CGSize labelSize	= [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
	label.frame			= CGRectMake(0.0,
									 0.0,
									 labelSize.width,
									 labelSize.height);

	CGFloat labelDegree	= ((layer.endDegree - layer.startDegree) * percentage) + layer.startDegree;
	CGPoint point		= [LoadingFlowSectionView pointOnCircleWithRadius:((self.outerRadius - self.innerRadius) / 2.0) + self.innerRadius andCenter:self.center atDegree:labelDegree];
	label.center		= point;

	[self addSubview:label];
}

- (void)highlightSection:(NSInteger)section withColor:(UIColor *)color
{
	ArcLayer *currentLayer	= _arcLayers[section];

	ArcLayer *arcLayer		= [[ArcLayer alloc] initWithLayer:currentLayer];
	arcLayer.frame			= self.bounds;
	arcLayer.fillColor		= color;

	[self.layer addSublayer:arcLayer];

	[_arcLayers addObject:arcLayer];
}

- (void)expandArcs
{
	[_arcLayers enumerateObjectsUsingBlock:^(ArcLayer *layer, NSUInteger idx, BOOL *stop) {
		// Add a transform of -180.0 to match the loading progress
		layer.endAngle = layer.endDegree - 180.0;
	}];
}

- (void)retractArcs
{
	[_arcLayers enumerateObjectsUsingBlock:^(ArcLayer *layer, NSUInteger idx, BOOL *stop) {
		// Add a transform of -180.0 to match the loading progress
		layer.endAngle = layer.startAngle;
	}];
}

+ (CGPoint)pointOnCircleWithRadius:(CGFloat)radius andCenter:(CGPoint)center atDegree:(CGFloat)degree
{
	// Add a transform of -180.0 to match the loading progress
	degree -= 180.0;
	return CGPointMake(center.x + (radius * cos(DEGREES_TO_RADIANS(degree))),
					   center.y + (radius * sin(DEGREES_TO_RADIANS(degree))));
}

@end
