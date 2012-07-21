//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Chris Snyder on 6/28/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

//adds number to program
- (void)pushOperand:(double)operand;

//adds variable to program
- (void)pushVariable:(NSString*)variable;

//adds variable to program
- (void)pushOperation:(NSString*)operation;

//removes last program operation
- (void)popLastOperation;

//runs program
- (double)performOperation:(NSString *)operation;

//runs program with specified variable vaules substituted for program variables 
- (double)performOperation:(NSString *)operation
       usingVariableValues:(NSDictionary *)variableValues; 

//completely clear the Calculator brain of data and state information
- (void)clear;

@property (readonly) id program;

//runs program
+ (double) runProgram:(id)program;

//runs program with specified variable vaules substituted for program variables 
+ (double) runProgram:(id)program 
  usingVariableValues:(NSDictionary *)variableValues;

//get set of variables used in program
+ (NSSet *)variablesUsedInProgram:(id)program;

//get the description of program suitable for printing
+ (NSString *) descriptionOfProgram:(id)program;

//get array of all programs in brain
+ (NSArray *) getAllPrograms:(id)program;

@end
