//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Chris Snyder on 6/28/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
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
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

///
///brain
/// Provides access to the calculator model
///
- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    
    if([digit isEqualToString:@"."]){
        if(!self.userIsInTheMiddleOfEnteringANumber){
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
        else if([self.display.text rangeOfString:@"."].location != NSNotFound){
            //disallow
            return;
        }            
    }
    
    if(self.userIsInTheMiddleOfEnteringANumber) {
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

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    self.historyDisplay.text = [NSString stringWithFormat:@"%@ %@", self.historyDisplay.text, self.display.text]; 
}

///
/// remove 1 character from the right of the currently displayed number
///
- (IBAction)backspace:(UIButton *)sender {
    int length = self.display.text.length;
    if (length>1)
    {
        self.display.text = [self.display.text substringToIndex:self.display.text.length-1];
        if ([self.display.text isEqualToString:@"-"]){
            // string is only the sign character make it 0
            self.display.text = @"0";
        }
    }
    else {
        self.display.text = @"0";
    }
}

///
/// Clear history, display, and calculator brain
///
- (IBAction)clear:(UIButton *)sender {
    self.historyDisplay.text = @"";
    self.display.text = @"0";
    [self.brain clear];
}

///
/// change the sign of the number being entered or if not currently entering a number the number on the RPN stack
///
- (IBAction)changeSign:(UIButton *)sender {
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

///
///process any operation which requires the calculator brain
- (IBAction)operationPressed:(UIButton *)sender {
    if(self.userIsInTheMiddleOfEnteringANumber){
        [self enterPressed];
    }
    NSString *operation = sender.currentTitle;
    self.historyDisplay.text = [NSString stringWithFormat:@"%@ %@ =", self.historyDisplay.text, operation]; 
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result]; 
}

- (void)viewDidUnload {
    [self setHistoryDisplay:nil];
    [super viewDidUnload];
}
@end
