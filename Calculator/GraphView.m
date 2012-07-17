//
//  GraphView.m
//  Calculator
//
//  Created by Chris Snyder on 7/14/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView()
@end

@implementation GraphView

#define ANCHOR_CENTER 0
#define ANCHOR_TOP 1
#define ANCHOR_LEFT 2
#define ANCHOR_BOTTOM 3
#define ANCHOR_RIGHT 4

#define HASH_MARK_FONT_SIZE 12.0

#define HORIZONTAL_TEXT_MARGIN 6
#define VERTICAL_TEXT_MARGIN 3

@synthesize programDescription = _programDescription;
@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;

#define DEFAULT_SCALE 1.0


-(void)setOrigin:(CGPoint)origin
{
    //todo Keep origin on screen
    _origin = origin;
    [self setNeedsDisplay];
}

- (CGFloat) scale
{
    if (!_scale)
    {
        return DEFAULT_SCALE;        
    }
    else {
        return _scale;
    }
}

- (void) setScale:(CGFloat)scale
{
    //scale of 100 keeps hash at 1 on screen
    if (_scale != scale && scale<=100)
    {
        _scale = scale;
                
        //redraw
        [self setNeedsDisplay];
    }
}

- (void) setup
{
    self.contentMode = UIViewContentModeRedraw;    
    [self addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];

    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self addGestureRecognizer:tapRecognizer];

    //initialize origin
    CGPoint midPoint;
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    self.origin = midPoint;
}

- (void) pinch:(UIPinchGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateChanged ||
       gesture.state == UIGestureRecognizerStateEnded)
    {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void) pan:(UIPanGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateChanged ||
       gesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint newOrigin = self.origin;
        CGPoint panPoint = [gesture translationInView:self];
        newOrigin.x += panPoint.x;
        newOrigin.y += panPoint.y;
        self.origin = newOrigin; 
        [gesture setTranslation:CGPointZero inView:self];
    }
}

-(void) tap:(UITapGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateChanged ||
       gesture.state == UIGestureRecognizerStateEnded)
    {
        self.origin = [gesture locationInView:self];
    }
}
     
- (void) awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

//Text drawing method based on method from AxesDrawer
+ (void)drawString:(NSString *)text atPoint:(CGPoint)location withAnchor:(int)anchor
{
	if ([text length])
	{
		UIFont *font = [UIFont systemFontOfSize:HASH_MARK_FONT_SIZE];
		
		CGRect textRect;
		textRect.size = [text sizeWithFont:font];
        
		textRect.origin.x = location.x - textRect.size.width / 2;
		textRect.origin.y = location.y - textRect.size.height / 2;
		
        textRect.origin = location;
		switch (anchor) {
			case ANCHOR_TOP: textRect.origin.y += textRect.size.height / 2 + VERTICAL_TEXT_MARGIN; break;
			case ANCHOR_LEFT: textRect.origin.x += textRect.size.width / 2+ HORIZONTAL_TEXT_MARGIN; break;
			case ANCHOR_BOTTOM: textRect.origin.y -= textRect.size.height / 2 + VERTICAL_TEXT_MARGIN; break;
			case ANCHOR_RIGHT: textRect.origin.x -= textRect.size.width / 2+ HORIZONTAL_TEXT_MARGIN; break;
		}
		
		[text drawInRect:textRect withFont:font];
	}
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw scale
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    //draw function    
    CGContextBeginPath(context);
    BOOL initialPointSet = NO;    
    for(int x=0; x<rect.size.width; x++)
    {
        CGFloat y = [self.dataSource getYforX:((x-self.origin.x)/self.scale)];
        //NSLog(@"gv call getYforX %g returned %g", ((x-self.origin.x)/self.scale), y);
              
        CGPoint nextPoint;
        nextPoint.x  = x;
        nextPoint.y = self.origin.y - y*self.scale;
        
        if(initialPointSet==YES)
        {
            CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y);
        }
        
        CGContextMoveToPoint(context, nextPoint.x, nextPoint.y);
        initialPointSet = YES;
    }
    
    //draw function in blue
    [[UIColor blueColor] setStroke];
    CGContextStrokePath(context);
    
    //reset draw color to black
    [[UIColor blackColor] setStroke];
    
    //draw program description
    NSString *programString = [self.dataSource getProgramDescription:self];
    
    [GraphView drawString:programString atPoint:CGPointZero withAnchor:ANCHOR_TOP];     
}

@end
