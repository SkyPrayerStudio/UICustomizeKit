//////////////////////////////////////////////////////////////////
//
//  BaseButton.m
//
//  Created by Dalton Cherry on 5/27/13.
//  Copyright (c) 2013 basement Krew. All rights reserved.
//
//////////////////////////////////////////////////////////////////

#import "BaseButton.h"
#import "UIColor+BaseColor.h"

@implementation BaseButton

//////////////////////////////////////////////////////////////////
-(void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
}
//////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}
//////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //draw the border
    if(self.borderWidth > 0)
    {
        frame = CGRectInset(frame, 0.5, 0.5);
        CGContextSaveGState(ctx);
        
        UIColor* color = self.borderColor;
        if(!color)
            color = [[self.colors lastObject] adjustColor:-0.12];
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextSetLineWidth(ctx, self.borderWidth);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:frame
                                               byRoundingCorners:self.corners
                                                     cornerRadii:CGSizeMake(self.rounding, self.rounding)].CGPath;
        CGContextAddPath(ctx, path);
        
        CGContextStrokePath(ctx);
        CGContextRestoreGState(ctx);
    }
    
    // draws body and gradient
    CGContextSaveGState(ctx);
    frame.origin.y -= 0.12;
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame, 0.2, 0.2)
                                           byRoundingCorners:self.corners
                                                 cornerRadii:CGSizeMake(self.rounding, self.rounding)].CGPath;
    
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    
    
    NSArray* array = self.colors;
    CGFloat* newGradientLocations = self.colorRange;
    if(!self.enabled && self.disabledColors)
    {
        array = self.disabledColors;
        if(self.disabledRange)
            newGradientLocations = self.disabledRange;
    }
    else if(self.highlighted && self.selectedColors)
    {
        array = self.selectedColors;
        if(self.selectedRange)
            newGradientLocations = self.selectedRange;
    }
    
    NSMutableArray* newGradientColors = [NSMutableArray arrayWithCapacity:array.count];
    for(UIColor* color in array)
        [newGradientColors addObject:(id)color.CGColor];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)newGradientColors, newGradientLocations);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(self.borderWidth, 0), CGPointMake(self.borderWidth, frame.size.height), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(ctx);
    
    //draw a white overlay over the button if disabled.
    /*if(!self.enabled)
    {
        CGContextSaveGState(ctx);
        // draws body
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
                                               byRoundingCorners:self.corners
                                                     cornerRadii:CGSizeMake(self.rounding, self.rounding)].CGPath;
        
        CGContextAddPath(ctx, path);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1 alpha:0.50].CGColor);
        CGContextFillPath(ctx);
        CGContextRestoreGState(ctx);
        
    }*/
    [super drawRect:rect];
}
//////////////////////////////////////////////////////////////////
-(void)cleanup
{
    if(self.colorRange)
    {
        free(self.colorRange);
        self.colorRange = NULL;
    }
    if(self.selectedRange)
    {
        free(self.selectedRange);
        self.selectedRange = NULL;
    }
    if(self.disabledRange)
    {
        free(self.disabledRange);
        self.disabledRange = NULL;
    }
}
//////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [self cleanup];
}
//////////////////////////////////////////////////////////////////

@end
