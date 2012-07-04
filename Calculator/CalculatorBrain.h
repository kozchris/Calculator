//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Chris Snyder on 6/28/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;

- (double)performOperation:(NSString *)operation;

//complete clear the Calculator brain of data and state information
- (void)clear;
@end
