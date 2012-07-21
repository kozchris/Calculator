//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Chris Snyder on 6/28/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic) NSDictionary *testVariableValues;

-(void)runProgram;
@end

@implementation CalculatorViewController
///
/// display shows will be sent to the brain or the result of a brain operation
///
@synthesize display = _display;

///
/// shows a history log of the calculator entries and operations
///
@synthesize historyDisplay = _historyDisplay;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

///
///brain
/// Provides access to the calculator model
///
- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Graph"])
    {
        ((GraphViewController*)segue.destinationViewController).programs = [CalculatorBrain getAllPrograms:self.brain.program];
    }
}

-(void)runProgram
{
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program]; 
    self.display.text = [NSString stringWithFormat:@"%g", result];   
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    
    if([digit isEqualToString:@"."])
    {
        if(!self.userIsInTheMiddleOfEnteringANumber)
        {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
        else if([self.display.text rangeOfString:@"."].location != NSNotFound)
        {
            //disallow
            return;
        }            
    }
    
    if(self.userIsInTheMiddleOfEnteringANumber) 
    {
        if (![digit isEqualToString:@"."] && [self.display.text isEqualToString:@"0"])        {
            //if display is 0 then set to digit unless digit is the decimal separator (numbers should not have a leading 0)
            self.display.Text = digit;
        }
        else {
            self.display.Text = [self.display.text stringByAppendingString:digit];
        }        
    } 
    else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    self.historyDisplay.text = [NSString stringWithFormat:@"%@ %@", self.historyDisplay.text, self.display.text]; 
}

///
/// remove 1 character from the right of the currently displayed number
///
- (IBAction)backspace:(UIButton *)sender 
{
    BOOL rerunProgram = YES;
    
    //if user is entering a number remove last digit
    //if number is completly removed then update display with last operation 
    if (self.userIsInTheMiddleOfEnteringANumber)
    {
        int displayLength = self.display.text.length;
        if (displayLength>1)
        {
            self.display.text = [self.display.text substringToIndex:displayLength-1];   
            rerunProgram = NO;
        }
        
        if ([self.display.text isEqualToString:@"-"])
        {        
            rerunProgram = YES;
        }
    }
    else {
        //user wants to undo the last operation
        [self.brain popLastOperation];        
    }
    
    if (rerunProgram)
    {
        self.userIsInTheMiddleOfEnteringANumber = NO;
        [self runProgram];
    }
}

///
/// Clear history, display, and calculator brain
///
- (IBAction)clear:(UIButton *)sender {
    self.historyDisplay.text = @"";
    self.display.text = @"0";
    self.variableDisplay.text = @"";
    self.testVariableValues = nil;
    [self.brain clear];
}

///
/// change the sign of the number being entered or if not currently entering a number the number on the RPN stack
///
- (IBAction)changeSign:(UIButton *)sender 
{
    if(self.userIsInTheMiddleOfEnteringANumber) {
        if ([@"-" isEqualToString:[self.display.text substringToIndex:1]]){
            //make positive
            self.display.text = [self.display.text substringFromIndex:1];
        }
        else {
            //make negative
            self.display.text = [@"-" stringByAppendingString:self.display.text];
        }
    }
    else {
        //treat as operand
        [self operationPressed:sender];
    }
}

- (IBAction)variablePressed:(UIButton *)sender 
{
    [self.brain pushVariable:sender.currentTitle];
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

///
///process any operation which requires the calculator brain
- (IBAction)operationPressed:(UIButton *)sender 
{
    if(self.userIsInTheMiddleOfEnteringANumber)
    {
        [self enterPressed];
    }
    NSString *operation = sender.currentTitle;
    [self.brain pushOperation:operation];
    
    [self runProgram];    
}

- (IBAction)variableInitButtonPressed:(UIButton *)sender 
{
    if ([sender.currentTitle isEqualToString:@"Test 1"])
    {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSDecimalNumber numberWithDouble:5], @"x",
                                   [NSDecimalNumber numberWithDouble:4.8], @"a",
                                   [NSDecimalNumber numberWithDouble:3], @"b",
                                   nil];
    }
    else if ([sender.currentTitle isEqualToString:@"Test 2"])
    {
        self.testVariableValues = nil;
    }
    else if ([sender.currentTitle isEqualToString:@"Test 3"])
    {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSDecimalNumber numberWithDouble:5], @"x",
                                   [NSDecimalNumber numberWithDouble:3], @"b",
                                   nil];
    }
    
    self.variableDisplay.text = @"";
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:self.brain.program]; 
    if (variablesUsed)
    {
        for (NSString *key in variablesUsed)
        {
            NSString *value = @"nil";
            id keyValue = [self.testVariableValues objectForKey:key];
            if ([keyValue isKindOfClass:[NSDecimalNumber class]])
            {
                value = [(NSDecimalNumber*)keyValue description];
            }
            self.variableDisplay.text = [NSString stringWithFormat:@"%@%@ = %@  ", self.variableDisplay.text, key, value];
        }
    }
}

- (IBAction)Graph:(UIButton *)sender {
    if (self.splitViewController!=nil)
    {
        //detail view is always in position 1, master in position 0
        if( [[self.splitViewController.viewControllers lastObject] isKindOfClass: [GraphViewController class]])
        {
            GraphViewController *graphViewController = [self.splitViewController.viewControllers lastObject];
            graphViewController.programs = [CalculatorBrain getAllPrograms:self.brain.program];
            
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.splitViewController)
        // on the iPad, we support all orientations
        return YES; 
    else
        // but no landscape on the iPhone, because I'm too lazy to fix the keypad
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)viewDidUnload 
{
    [self setHistoryDisplay:nil];
    [self setVariableDisplay:nil];    
    [super viewDidUnload];
}
@end
