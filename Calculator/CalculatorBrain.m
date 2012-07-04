//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Chris Snyder on 6/28/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain() 
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray *)operandStack
{
    if(!_operandStack)
    {
        _operandStack = [[NSMutableArray alloc] init];
    }
    return _operandStack;
}

- (void)clear
{
    [self.operandStack removeAllObjects];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.operandStack addObject:operandObject];
}

- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    return  [operandObject doubleValue];
}

///
///handles all brain operations
///
- (double)performOperation:(NSString *)operation
{
    double result = 0;
    
    if([operation isEqualToString:@"+"])
    {
        result = [self popOperand] + [self popOperand];
    }
    else if ([@"*" isEqualToString:operation])
    {
        result = [self popOperand] * [self popOperand];
    }
    else if([operation isEqualToString:@"-"])
    {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
    }
    else if([operation isEqualToString:@"/"])
    {
        double divisor = [self popOperand];
        if (divisor) result = [self popOperand] / divisor;
    }
    else if([operation isEqualToString:@"sin"])
    {
        result = sin([self popOperand]);
    }
    else if([operation isEqualToString:@"cos"])
    {
        result = cos([self popOperand]);
    }
    else if([operation isEqualToString:@"sqrt"])
    {
        result = sqrt([self popOperand]);
    }
    else if([operation isEqualToString:@"pi"])
    {
        [self pushOperand:M_PI];
        
        result = M_PI;
    }
    else if([operation isEqualToString:@"+/-"])
    {
        result = -1 * [self popOperand];
    }
    
    
    [self pushOperand:result];
    
    return result;
}

@end
