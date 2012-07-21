//
//  GraphViewController.m
//  Calculator
//
//  Created by Chris Snyder on 7/14/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize toolbar = _toolbar;

-(void) setProgram:(id)program
{
    if (_program != program)
    {
        [self.graphView setNeedsDisplay];
        _program = program;
    }
}

-(void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    self.graphView.dataSource = self;
}

-(NSString*)getProgramDescription:(GraphView*) sender
{
    return [CalculatorBrain descriptionOfProgram:self.program];
}

-(float) getYforX:(float)x
{
    NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:[NSDecimalNumber numberWithFloat:x], @"x", nil]; 
    return [CalculatorBrain runProgram:self.program usingVariableValues:vars];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void) awakeFromNib
{
    self.splitViewController.delegate = self;
    
    [super awakeFromNib];
}

-(void)viewDidLoad
{
    if( [self.view isKindOfClass:[GraphView class]])
    {
        GraphView *graphView = (GraphView*)self.view;
        //save state
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"scale"]!=nil)
        {
            graphView.scale = [defaults floatForKey:@"scale"];
        }
        
        if ([defaults objectForKey:@"origin.x"] != nil)
        {
            CGPoint origin;        
            origin.x = [defaults floatForKey:@"origin.x"];
            origin.y = [defaults floatForKey:@"origin.y"];
            graphView.origin = origin;
        }
        
        if (self.splitViewController)
        {
            self.masterPopoverController = [[UIPopoverController alloc] initWithContentViewController:[self.splitViewController.viewControllers objectAtIndex:0]];
        }
    }
    
    [super viewDidLoad];
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    
    if( [self.view isKindOfClass:[GraphView class]])
    {
        GraphView *graphView = (GraphView*)self.view;
        //save state
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:graphView.scale forKey:@"scale"];
        
        [defaults setFloat:graphView.origin.x forKey:@"origin.x"];
        [defaults setFloat:graphView.origin.y forKey:@"origin.y"];
        
        [defaults synchronize];
    }
    
    [super viewWillDisappear:animated];
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Calculator";
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    
    //pc.popoverArrowDirection = UIPopoverArrowDirectionDown;
    self.masterPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:button];
    self.toolbar.items = toolbarItems;
    self.masterPopoverController = nil;
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setToolbar:nil];
    [self setToolbar:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}
@end
