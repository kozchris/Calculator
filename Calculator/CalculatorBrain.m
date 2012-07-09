//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Chris Snyder on 6/28/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import "CalculatorBrain.h"
@interface BrainOperator : NSObject

typedef enum enumOperatorType { kOperator, kVariable, kFunction, kConstant } enumOperatorType; 
@property (nonatomic, strong) NSString *operatorName;
@property enumOperatorType operatorType;
@property int operandCount;

+ (BrainOperator*) initWithName:(NSString*)p_name
                   operatorType: (enumOperatorType)p_type;

+ (BrainOperator*) initWithName:(NSString*)p_name
                   operatorType: (enumOperatorType)p_type
                   operandCount:(int)p_operandCount;

-(NSString*) description;

@end

@implementation BrainOperator
@synthesize operatorName = _operatorName;
@synthesize operatorType = _operatorType;
@synthesize operandCount = _operandCount;

+ (BrainOperator*) initWithName:(NSString*)p_name
                   operatorType: (enumOperatorType)p_operatorType
{
    return [BrainOperator initWithName:p_name operatorType:p_operatorType operandCount:0];
}

+ (BrainOperator*) initWithName:(NSString*)p_name
                   operatorType: (enumOperatorType)p_operatorType
                   operandCount:(int)p_operandCount
{
    BrainOperator *result;
    result = [[BrainOperator alloc] init];
    result.operatorName = p_name;
    result.operatorType = p_operatorType;
    result.operandCount = p_operandCount;
    
    return result;
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"Name=%@, Type=%d, operandCount=%d", self.operatorName, self.operatorType, self.operandCount];
}

@end

@interface CalculatorBrain() 
@property (nonatomic, strong) NSMutableArray *programStack; 
@property (nonatomic, strong, readonly) NSDictionary *operationDictionary;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize operationDictionary = _operationDictionary;

//constant set of available operations
+ (NSDictionary *)operationDictionary
{
    static NSDictionary *m_operations;
    if(!m_operations)
    {
        m_operations = [NSDictionary dictionaryWithObjectsAndKeys:
                        [BrainOperator initWithName:@"+" 
                                       operatorType:kOperator 
                                       operandCount:2 ], @"+",
                        [BrainOperator initWithName:@"*" 
                                       operatorType:kOperator 
                                       operandCount:2 ], @"*",
                        [BrainOperator initWithName:@"-" 
                                       operatorType:kOperator 
                                       operandCount:2 ], @"-",
                        [BrainOperator initWithName:@"/" 
                                       operatorType:kOperator 
                                       operandCount:2 ], @"/",
                        [BrainOperator initWithName:@"sin" 
                                       operatorType:kFunction 
                                       operandCount:1 ], @"sin",
                        [BrainOperator initWithName:@"cos" 
                                       operatorType:kFunction 
                                       operandCount:1 ], @"cos",
                        [BrainOperator initWithName:@"sqrt" 
                                       operatorType:kFunction
                                       operandCount:1 ], @"√", 
                        [BrainOperator initWithName:@"π" 
                                       operatorType:kConstant ], @"π",
                        [BrainOperator initWithName:@"+/-" 
                                       operatorType:kOperator 
                                       operandCount:1 ], @"+/-",
                        [BrainOperator initWithName:@"x" 
                                       operatorType:kVariable ], @"x",
                        [BrainOperator initWithName:@"a" 
                                       operatorType:kVariable ], @"a",
                        [BrainOperator initWithName:@"b" 
                                       operatorType:kVariable ], @"b",
                        nil];  
    }
    return m_operations;
}


- (NSMutableArray *)programStack
{
    if(!_programStack)
    {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id) program {
    return [self.programStack copy] ;
}

+ (BOOL)isOperation:(NSString *)operation
{
    BOOL result = NO;
    BrainOperator *operator = [CalculatorBrain.operationDictionary objectForKey:operation]; 
    if (operator!=nil && operator.operatorType!=kVariable)
    {
        result = YES;
    }
    return result;
}

+ (BOOL)isVariable:(NSString *)operation
{
    BOOL result = NO;
    BrainOperator *operator = [CalculatorBrain.operationDictionary objectForKey:operation]; 
    if (operator!=nil && operator.operatorType==kVariable)
    {
        result = YES;
    }
    return result;
}

- (void)clear
{
    [self.programStack removeAllObjects];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)pushVariable:(NSString*)variable
{
    [self.programStack addObject:variable]; 
}

- (void)pushOperation:(NSString*)operation
{
    BrainOperator *operator = [CalculatorBrain.operationDictionary objectForKey:operation]; 
    if (operator)
    {
        //make sure there are enough operands to perform operation
        int operandsNeeded = 0;
        for (NSString *operation in self.programStack) {
            
            BrainOperator *programOperator = [CalculatorBrain.operationDictionary objectForKey:operation]; 
            if (programOperator) {
                if (programOperator.operatorType==kFunction || programOperator.operatorType==kOperator) {
                    operandsNeeded += programOperator.operandCount;
                }
            }
        }
        
        //everything on stack is or creates an operand 
        //therefore we only need to subtract the operands needed from the stack count        
        //to get the number of available operands
        if (self.programStack.count - operandsNeeded >= operator.operandCount)
        {
            [self.programStack addObject:operation];
        }
    }
}

- (void)popLastOperation
{
    [self.programStack removeLastObject]; 
}

///
///handles all brain operations
///
- (double)performOperation:(NSString *)operation
{
    return [self performOperation:operation usingVariableValues:nil];
}

///
///handles all brain operations with variables
///
- (double)performOperation:(NSString *)operation
       usingVariableValues:(NSDictionary *)variableValues 

{    
    [self pushOperation:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
}

+ (NSString *) getDescriptionOfOperation:(NSMutableArray *)stack 
{
    NSString *result = @"unrecognized operation";
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack description];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        BrainOperator *operator = [CalculatorBrain.operationDictionary objectForKey:operation]; 
        if (operator.operatorType!=kVariable)
        { 
            if (operator.operatorType==kOperator)
            {
                
                if (operator.operandCount==2)
                {
                    
                    NSString *lastOperation = [self getDescriptionOfOperation:stack];
                    //*, /, +, -
                    result = [NSString stringWithFormat:@"(%@ %@ %@)", [self getDescriptionOfOperation:stack], operator.operatorName, lastOperation ];
                }
                else {
                    //+/-
                    result = [NSString stringWithFormat:@"%@ %@)", operator.operatorName, [self getDescriptionOfOperation:stack]];
                    
                }               
            }
            else if (operator.operatorType==kFunction)
            {                
                result = [NSString stringWithFormat:@"%@(%@)", operator.operatorName, [self getDescriptionOfOperation:stack]];
            }
            else if (operator.operatorType==kConstant)
            {
                result = operator.operatorName;
            }
        }
        else
        {
            result = operator.operatorName;
        }    
    }
    return result;
}

+ (NSString *) descriptionOfProgram:(id)program 
{
    NSString *result = @"";
    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
        while([stack lastObject])
        {
            if (![result isEqualToString:@""])
            {
                result = [NSString stringWithFormat:@", %@", result];    
            }
            result = [NSString stringWithFormat:@"%@%@", [self getDescriptionOfOperation:stack], result];
        }
    }
    return result;
}


+ (double) popOperandOffStack:(NSMutableArray *) stack 
          usingVariableValues:(NSDictionary *)variableValues 
{
    double result = 0;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([self isOperation:operation])
        {
            if([operation isEqualToString:@"+"])
            {
                result = [self popOperandOffStack:stack usingVariableValues:variableValues] + [self popOperandOffStack:stack usingVariableValues:variableValues];
            }
            else if ([@"*" isEqualToString:operation])
            {
                result = [self popOperandOffStack:stack usingVariableValues:variableValues] * [self popOperandOffStack:stack usingVariableValues:variableValues];
            }
            else if([operation isEqualToString:@"-"])
            {
                double subtrahend = [self popOperandOffStack:stack usingVariableValues:variableValues];
                result = [self popOperandOffStack:stack usingVariableValues:variableValues] - subtrahend;
            }
            else if([operation isEqualToString:@"/"])
            {
                double divisor = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if (divisor) 
                {
                    result = [self popOperandOffStack:stack usingVariableValues:variableValues] / divisor;
                }
            }
            else if([operation isEqualToString:@"sin"])
            {
                double divisor = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if (divisor)
                {
                    result = sin(M_PI/180 * divisor);   
                }
            }
            else if([operation isEqualToString:@"cos"])
            {
                result = cos([self popOperandOffStack:stack usingVariableValues:variableValues] * M_PI/180);
            }
            else if([operation isEqualToString:@"√"])
            {
                result = sqrt([self popOperandOffStack:stack usingVariableValues:variableValues]);
            }
            else if([operation isEqualToString:@"π"])
            {
                result = M_PI;
            }
            else if([operation isEqualToString:@"+/-"])
            {
                result = -1 * [self popOperandOffStack:stack usingVariableValues:variableValues];
            }  
        }
        else if ([self isVariable:operation])
        {
            NSNumber *variableValue = [variableValues objectForKey:operation];
            if (variableValue) 
            {
                result = [variableValue doubleValue];
            }   
        }
    }
    
    return result;
}

///
/// run program assuming any variables are set to 0
///
+ (double) runProgram:(id)program  
{
    return [self runProgram:program usingVariableValues:nil];
}

///
/// run program using the variables specified
///
+ (double) runProgram:(id)program 
  usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    return [self popOperandOffStack:stack usingVariableValues:variableValues];
}

///
/// return the ids of all variables used in program
///
+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSSet *result;
    
    if ([program isKindOfClass:[NSArray class]])
    {
        NSArray *stack = program;
        
        for (id value in stack)
        {
            if ([value isKindOfClass:[NSString class]] && [self isVariable:value])
            {
                //found variable used by program, add to set
                if (!result) result = [[NSSet alloc] init]; 
                
                result = [result setByAddingObject:value];
            }
        }            
    }
    
    return result;
}

@end
