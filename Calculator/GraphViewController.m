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

@end
