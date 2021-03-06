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
@synthesize fillColor, startDegree, endDegree, innerRadius, animationDuration;

- (id)init
{
	if (!(self = [super init]))
        return self;

	self.fillColor			= [[UIColor blackColor] colorWithAlphaComponent:0.5];
	self.startAngle			= 0.0;
	self.endDegree			= 0.0;
	self.innerRadius		= 0.0;
	self.outerRadius		= 0.0;
	self.animationDuration	= 0.5;

	[self setNeedsDisplay];

    return self;
}

- (id)initWithLayer:(id)layer
{
	if (self = [super initWithLayer:layer])
	{
		if ([layer isKindOfClass:[LoadingArcLayer class]])
		{
			LoadingArcLayer *other	= (LoadingArcLayer *)layer;
			self.startAngle			= other.startAngle;
			self.endAngle			= other.endAngle;
			self.startDegree		= other.startDegree;
			self.endDegree			= other.endDegree;
			self.fillColor			= other.fillColor;
			self.innerRadius		= other.innerRadius;
			self.outerRadius		= other.outerRadius;
			self.animationDuration	= other.animationDuration;
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
	anim.duration			= self.animationDuration;

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
	BOOL clockwise			= DEGREES_TO_RADIANS(self.startAngle) > DEGREES_TO_RADIANS(self.endAngle);

	// Outer arc
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, center.x, center.y);

	CGPoint pointOuter		= CGPointMake(center.x + self.outerRadius * cosf(DEGREES_TO_RADIANS(self.startAngle)),
										  center.y + self.outerRadius * sinf(DEGREES_TO_RADIANS(self.startAngle)));
	CGContextAddLineToPoint(ctx, pointOuter.x, pointOuter.y);
	CGContextAddArc(ctx, center.x, center.y, self.outerRadius, DEGREES_TO_RADIANS(self.startAngle), DEGREES_TO_RADIANS(self.endAngle), clockwise);
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

- (void)startDancingWithDelay:(NSTimeInterval)delay
{
	[self performSelector:@selector(chachaForward) withObject:nil afterDelay:delay];
}

- (void)chachaForward
{
	self.endAngle = self.endDegree - 180.0;

	[self performSelector:@selector(chachaBack) withObject:nil afterDelay:self.animationDuration];
}

- (void)chachaBack
{
	self.startAngle = self.endAngle;

	[self performSelector:@selector(bootyPop) withObject:nil afterDelay:self.animationDuration];
}

- (void)bootyPop
{
	self.startAngle	= self.startDegree - 180.0;
	self.endAngle	= self.startDegree - 180.0;

	self.transform = CATransform3DRotate(self.transform, DEGREES_TO_RADIANS(45.0), 0.0, 0.0, 1.0);


	[self performSelector:@selector(chachaForward) withObject:nil afterDelay:self.animationDuration];
}

@end
