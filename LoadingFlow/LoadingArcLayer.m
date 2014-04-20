//
//  ArcLayer.m
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 4/19/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//
//	Changed code found at https://github.com/pavanpodila/PieChart

#import "LoadingArcLayer.h"

#define DEGREES_TO_RADIANS(degrees)	((M_PI * degrees) / 180.0)

@implementation LoadingArcLayer

@dynamic startAngle, endAngle;
@synthesize fillColor, startDegree, endDegree, innerRadius;

- (id)init
{
	if (!(self = [super init]))
        return self;

	[self setNeedsDisplay];

    return self;
}

- (id)initWithLayer:(id)layer
{
	if (self = [super initWithLayer:layer])
	{
		if ([layer isKindOfClass:[LoadingArcLayer class]])
		{
			LoadingArcLayer *other		= (LoadingArcLayer *)layer;
			self.startAngle		= other.startAngle;
			self.endAngle		= other.endAngle;
			self.startDegree	= other.startDegree;
			self.endDegree		= other.endDegree;
			self.fillColor		= other.fillColor;
			self.innerRadius	= other.innerRadius;
		}
	}

	return self;
}

-(id<CAAction>)actionForKey:(NSString *)event
{
	if ([event isEqualToString:@"startAngle"] || [event isEqualToString:@"endAngle"])
		return [self makeAnimationForKey:event];

	return [super actionForKey:event];
}

-(CABasicAnimation *)makeAnimationForKey:(NSString *)key
{
	CABasicAnimation *anim	= [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue			= [[self presentationLayer] valueForKey:key];
	anim.timingFunction		= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration			= 0.5;

	return anim;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
	if ([key isEqualToString:@"startAngle"] || [key isEqualToString:@"endAngle"])
		return YES;

	return [super needsDisplayForKey:key];
}

-(void)drawInContext:(CGContextRef)ctx
{
	CGPoint center			= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	CGFloat outerRadius		= MIN(center.x, center.y);
	BOOL clockwise			= DEGREES_TO_RADIANS(self.startAngle) > DEGREES_TO_RADIANS(self.endAngle);

	// Outer arc
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, center.x, center.y);

	CGPoint pointOuter		= CGPointMake(center.x + outerRadius * cosf(DEGREES_TO_RADIANS(self.startAngle)),
										  center.y + outerRadius * sinf(DEGREES_TO_RADIANS(self.startAngle)));
	CGContextAddLineToPoint(ctx, pointOuter.x, pointOuter.y);
	CGContextAddArc(ctx, center.x, center.y, outerRadius, DEGREES_TO_RADIANS(self.startAngle), DEGREES_TO_RADIANS(self.endAngle), clockwise);
	CGContextClosePath(ctx);

	CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
	CGContextSetLineWidth(ctx, 0.0);

	CGContextDrawPath(ctx, kCGPathFillStroke);

	// Inner arc
	CGContextSetBlendMode(ctx, kCGBlendModeClear); // This blend mode will clear the area of the draw

	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, center.x, center.y);
	CGPoint pointInner		= CGPointMake(center.x + self.innerRadius * cosf(DEGREES_TO_RADIANS(self.startAngle)),
										  center.y + self.innerRadius * sinf(DEGREES_TO_RADIANS(self.startAngle)));
	CGContextAddLineToPoint(ctx, pointInner.x, pointInner.y);
	CGContextAddArc(ctx, center.x, center.y, self.innerRadius, DEGREES_TO_RADIANS(self.startAngle), DEGREES_TO_RADIANS(self.endAngle), clockwise);
	CGContextClosePath(ctx);

	// The clear blend mode still leaves some sort rogue pixels so this extension of width takes care of that
	CGContextSetLineWidth(ctx, 5.0);

	CGContextDrawPath(ctx, kCGPathFillStroke);
}


@end
