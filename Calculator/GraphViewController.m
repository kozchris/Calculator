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
#import "FavoritesTableViewController.h"

@interface GraphViewController () <GraphViewDataSource, FavoritesTableViewControllerDelegate>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize programs = _programs;
@synthesize graphView = _graphView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize toolbar = _toolbar;
@synthesize drawingModeSwitch = _drawingModeSwitch;

-(NSArray*)programs
{
    if (!_programs)
    {
        return [NSArray array];
    }
    return _programs;
}

-(void) setPrograms:(NSArray *)programs
{
    if (_programs != programs)
    {
        [self.graphView setNeedsDisplay];
        _programs = programs;
    }
}

-(void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    self.graphView.dataSource = self;
}

-(NSString*)getProgramDescription:(GraphView*) sender withProgramNumber:(int) programNumber
{
    return [CalculatorBrain descriptionOfProgram:[self.programs objectAtIndex:programNumber]];
}

-(int) getProgramCount
{
    return self.programs.count;
}

-(float) getYforX:(float)x withProgramNumber:(int) programNumber
{
    NSDictionary *vars = [NSDictionary dictionaryWithObjectsAndKeys:[NSDecimalNumber numberWithFloat:x], @"x", nil]; 
    return [CalculatorBrain runProgram:[self.programs objectAtIndex:programNumber] usingVariableValues:vars];
}

-(enumDrawingMode)getDrawingMode
{    
    if(!self.drawingModeSwitch.isOn )
    {
        return (enumDrawingMode)kDot;
    }
    else {
        return (enumDrawingMode)kLine;
    }
}

- (IBAction)DrawingModeChanged:(UISwitch *)sender {
    [self.graphView setNeedsDisplay];
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

#define FAVORITES_KEY @"CalculatorGraphViewController.Favorites"

- (IBAction)addToFavorites:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites)
    {
        favorites = [NSMutableArray array];
    }
    
    //add all programs being displayed to favorites
    for (int programNumber = 0; programNumber<self.programs.count;programNumber++) {
        [favorites addObject:[self.programs objectAtIndex:programNumber]];
    }
    
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    
    [defaults synchronize];
}

- (NSArray*)removeProgramFromFavorites:(id)program {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites)
    {
        favorites = [NSMutableArray array];
    }
    
    [favorites removeObjectIdenticalTo:program];
    
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    
    [defaults synchronize];
    
    return favorites;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"])
    {
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms: programs];
        [segue.destinationViewController setDelegate:self];
    }
}

-(void) favoritesTableViewController:(FavoritesTableViewController*)sender choseProgram:(id)program
{
    NSMutableArray *tPrograms = [self.programs mutableCopy];
    [tPrograms addObject:program];
    self.programs = tPrograms ;
    
    
    // if you wanted to close the popover when a graph was selected
    // you could uncomment the following line
    // you'd probably want to set self.popoverController = nil after doing so
    // [self.popoverController dismissPopoverAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) favoritesTableViewController:(FavoritesTableViewController *)sender deletedProgram:(id)program
{
    sender.programs = [self removeProgramFromFavorites:program];     
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setToolbar:nil];
    [self setToolbar:nil];
    [self setToolbar:nil];
    [self setDrawingModeSwitch:nil];
    [super viewDidUnload];
}
@end
