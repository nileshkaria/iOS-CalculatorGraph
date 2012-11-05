//
//  CalculatorGraphView.m
//  CalculatorGraph
//
//  Created by Nilesh Karia on Oct/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorGraphView.h"
#import "AxesDrawer.h"

@implementation CalculatorGraphView

@synthesize scale       = _scale;
@synthesize axisOrigin  = _axisOrigin;
@synthesize dataSource  = _dataSource;

#define DEFAULT_SCALE 1

- (CGFloat) scale
{
    if(!_scale)
        return DEFAULT_SCALE;
    else   
        return _scale;
}

- (void)setScale:(CGFloat)scale
{
    if(scale != _scale)
    {
        _scale = scale;
        
        //Get the scale from the delegate ie. the controller
        [self.dataSource storeScale:_scale forGraphView:self];
        
        [self setNeedsDisplay];
    }
}

- (CGPoint) axisOrigin
{
    //Set initial values
    if(!_axisOrigin.x && !_axisOrigin.y)
    {
        CGFloat width   = self.bounds.size.width/2;
        CGFloat height  = self.bounds.size.height/2;
        
        if(width < height)
        {
            _axisOrigin.x = self.bounds.origin.x + width;
            _axisOrigin.y = self.bounds.origin.y + height;
        }
        else
        {
            _axisOrigin.x = self.bounds.origin.x + height;
            _axisOrigin.y = self.bounds.origin.y + width;        
        }
    }
    
    return _axisOrigin;
}

- (void)setAxisOrigin:(CGPoint)axisOrigin
{
    if(axisOrigin.x == _axisOrigin.x && axisOrigin.y == _axisOrigin.y)
        return;
    
    _axisOrigin = axisOrigin;

    //Get the axisOrigin from the delegate ie. the controller
    [self.dataSource storeAxisOrigin:_axisOrigin forGraphView:self];

    [self setNeedsDisplay];
}

- (void) pinch:(UIPinchGestureRecognizer *)gesture
{
    if((gesture.state != UIGestureRecognizerStateChanged) ||
       (gesture.state != UIGestureRecognizerStateEnded))
    {
        self.scale *= gesture.scale;

        //Reset gesture scale
        gesture.scale = 1;
    }
}

- (void) pan:(UIPanGestureRecognizer *)gesture
{
    if((gesture.state != UIGestureRecognizerStateChanged) ||
        (gesture.state != UIGestureRecognizerStateEnded))
    {
        //Move the origin of the graph
        CGPoint translation = [gesture translationInView:self];
        
        //Change axis points here and get new graph point values
        CGPoint axisOrigin;
        axisOrigin.x = self.axisOrigin.x + translation.x;
        axisOrigin.y = self.axisOrigin.y + translation.y;
        
        self.axisOrigin = axisOrigin;        
        
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void) setup
{
    self.contentMode = UIViewContentModeRedraw;
}

- (void) awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) 
    {
        // Initialization code
        // This code will redraw content on rotation
        [self setup];
    }
    
    return self;
}

- (void) drawCircleAtPoint: (CGPoint) p
                withRadius: (CGFloat) radius
                 inContext: (CGContextRef) context
{
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

/*
- (void) drawCurveToPoint: (CGPoint) toPoint
                fromPoint: (CGPoint) fromPoint
                inContext: (CGContextRef) context
{
    UIGraphicsPushContext(context);
    
    CGContextSetLineWidth(context, 3.0);
    [[UIColor orangeColor] setStroke];
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddArcToPoint(context, fromPoint.x, fromPoint.y, toPoint.x, toPoint.y, 2*M_PI);
    //CGContextAddCurveToPoint(context, fromPoint.x, fromPoint.y, toPoint.x, toPoint.y, toPoint.x, toPoint.y);
    
    CGContextStrokePath(context);

    UIGraphicsPopContext();
}
 */

- (CGPoint) convertPointToGraphCoordinate:(CGPoint)screenCoordinatePoint
{
    CGPoint graphCoordinatePoint;
    
    //The user defined _scale is variable while self.contentScaleFactor is not! Use _scale here. 
    graphCoordinatePoint.x = (screenCoordinatePoint.x - self.axisOrigin.x)/self.scale;
    graphCoordinatePoint.y = (self.axisOrigin.y - screenCoordinatePoint.y )/self.scale;
    
    return graphCoordinatePoint;    
}

- (CGPoint) convertPointToScreenCoordinate:(CGPoint)graphCoordinatePoint
{
    CGPoint screenCoordinatePoint;
    
    //The user defined _scale is variable while self.contentScaleFactor is not! Use _scale here. 
    screenCoordinatePoint.x = (graphCoordinatePoint.x * self.scale) + self.axisOrigin.x;
    screenCoordinatePoint.y = self.axisOrigin.y - (graphCoordinatePoint.y * self.scale);
    
    return screenCoordinatePoint; 
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint midpoint;
    midpoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midpoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    
    CGFloat size = self.bounds.size.width/2;
    
    if(self.bounds.size.height < self.bounds.size.width)
        size = self.bounds.size.height/2;
    
    size *= self.scale;
    
    CGContextSetLineWidth(context, 2.0);
    [[UIColor darkGrayColor] setStroke];
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.axisOrigin scale:self.scale];
    
    CGPoint currPoint, prevPoint;
    
    //NOTE - First convert points from screen coordinates to graph coordinates and get the 
    //function resultant value. Then reconvert the result into screen coordinates to draw
    prevPoint.x = self.bounds.origin.x;
    prevPoint = [self convertPointToGraphCoordinate:prevPoint];
    prevPoint.y = [self.dataSource functionValueForVariable:prevPoint.x forGraphView:self];
    prevPoint = [self convertPointToScreenCoordinate:prevPoint];
    
    CGContextSetLineWidth(context, 3.0);
    [[UIColor greenColor] setStroke];
    CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
    
    CGFloat increment = 1/[self contentScaleFactor];    
    
    for (int x = self.bounds.origin.x; x <= self.bounds.origin.x + self.bounds.size.width; x += increment) 
    {
        currPoint.x = x;
        currPoint = [self convertPointToGraphCoordinate:currPoint];
        currPoint.y = [self.dataSource functionValueForVariable:currPoint.x forGraphView:self];
        
        NSLog(@"Graph x=%f", currPoint.x);
        NSLog(@"Graph y=%f", currPoint.y);
        
        currPoint = [self convertPointToScreenCoordinate:currPoint];
                
        //Don't draw points which are not within bounds
        if(currPoint.y == NAN || currPoint.y == INFINITY || currPoint.y == -INFINITY)
            continue;
        
        NSLog(@"Screen x=%f", currPoint.x);
        NSLog(@"Screen y=%f", currPoint.y);
        
        //NOTE - This does not work for examples like sin(x) when the axes span a large range 
        //CGContextAddArcToPoint(context, prevPoint.x, prevPoint.y, currPoint.x, currPoint.y, 2*M_PI);
        
        CGContextAddArc(context, currPoint.x, currPoint.y, increment/2.0, 0, 2*M_PI, YES);
        
        prevPoint = currPoint;
    }
    
    CGContextStrokePath(context);
    
}

@end
