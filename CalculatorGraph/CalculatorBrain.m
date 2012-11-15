//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Nil on May/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSMutableArray *infixStack;
@property (nonatomic, strong) NSMutableArray *formulaStack;
@property (nonatomic, strong) NSSet *variableSet;
@property (nonatomic, strong) NSMutableDictionary *variableValues;

@end


@implementation CalculatorBrain

@synthesize programStack   = _programStack;
@synthesize infixStack     = _infixStack;
@synthesize formulaStack   = _formulaStack;
@synthesize variableSet    = _variableSet;
@synthesize variableValues = _variableValues;

- (NSMutableArray*) programStack
{
    if(!_programStack)
        _programStack = [[NSMutableArray alloc] init];
    
    return _programStack;
}

- (NSMutableArray *) infixStack
{
  if(!_infixStack)
      _infixStack = [[NSMutableArray alloc] init];
    
    return _infixStack;
}

- (NSMutableArray *) formulaStack
{
    if(!_formulaStack)
        _formulaStack = [[NSMutableArray alloc] init];
    
    return _formulaStack;
}

- (NSSet *) variableSet
{
    if(!_variableSet)
        _variableSet = [[NSSet alloc] init];
    
    return _variableSet;
}

- (NSMutableDictionary *) variableValues
{
    if(!_variableValues)
        _variableValues = [[NSMutableDictionary alloc] init];
    
    return _variableValues;
}

- (id)program
{
    return [self.programStack copy];
}

- (id)infix
{
    return [self.infixStack copy];
}

- (id)formula
{
    return [self.formulaStack copy];
}

- (void) clearStack
{
    [self.programStack removeAllObjects];
    [self.infixStack removeAllObjects];
    [self.formulaStack removeAllObjects];
}

- (void) pushOperand:(double) operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void) pushFormula:(double) operand
{
    [self.formulaStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void) pushInfix:(double) operand
{
    [self.infixStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void) pushVariable:(NSString *)operand
{
    [self.programStack addObject:operand];
    [self.infixStack addObject:operand];
    [self.formulaStack addObject:operand];
    [self.variableSet  setByAddingObject:operand];
}

- (void) assignValueToVariable:(id)value
                 usingVariable:(NSString *)variable
{
    NSLog(@"Key = %@", variable);
    
    [self.variableValues setValue:value 
                           forKey:variable];
}

- (double) popOperand
{
    NSNumber * operandObject = [self.programStack lastObject];
    
    if(operandObject)
        [self.programStack removeLastObject];
    
    return [operandObject doubleValue];
}

- (double) performOperationUsingVariables
{
    NSArray * keys = [self.variableValues allKeys];
    NSArray * values = [self.variableValues allValues];
    
    for(NSUInteger i = 0; i < [keys count]; ++i) 
    {
        //NSLog(@"Key: %g ", [keys objectAtIndex:i]);
        NSLog(@"Key: %@ ", [keys objectAtIndex:i]);
        NSLog(@"Value: %f ", [[values objectAtIndex:i] doubleValue]);
    }
    
    return [CalculatorBrain runProgram:self.formulaStack
                   usingVariableValues:self.variableValues];
}

- (double) removeLastObjectAndPerformOperation;
{
    [self.programStack removeLastObject];
    
    if([[self.programStack lastObject] isKindOfClass:[NSString class]])
        [self.programStack removeLastObject];
    
    [self.infixStack removeAllObjects];
    [self.infixStack addObjectsFromArray:[self.programStack copy]];
    
    [self.formulaStack removeLastObject];
    
    return [CalculatorBrain runProgram:self.program];
}

- (double) performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    [self.infixStack addObject:operation];
    [self.formulaStack addObject:operation];
    
    return [CalculatorBrain runProgram:self.program];
}

- (NSString *) descriptionOfTopOfStack
{
    NSMutableArray * infixArray = [[NSMutableArray alloc] init];
        
    [CalculatorBrain    generateInfix:infixArray
                      usingInfixStack:[self.infix mutableCopy]];
    
    if ([infixArray count]) 
    {
        //Clear the infix stack so that we don't start the next
        //display all over. 
        [self.infixStack removeAllObjects];
        [self.infixStack addObjectsFromArray:infixArray];
        
        NSString * infixArrayString = @"";
        
        for(NSUInteger i = 0; i < [self.infixStack count]; ++i)
        {
            //NSLog(@"Array value %@", (NSString *)[self.infixStack objectAtIndex:i]);
            
            infixArrayString = [[infixArrayString stringByAppendingString:@" "] stringByAppendingString:(NSString *)[self.infixStack objectAtIndex:i]];
        }
        
        //NSLog(@"Infix String = [%@]", infixArrayString);
        
        return infixArrayString;
    }
    
    return nil;
}

+ (NSString *) descriptionOfProgram:(NSMutableArray *)stack
{
    NSMutableArray * infixArray = [[NSMutableArray alloc] init];
    
    [CalculatorBrain    generateInfix:infixArray
                      usingInfixStack:[stack mutableCopy]];
    
    if ([infixArray count]) 
    {
        //Clear the infix stack so that we don't start the next
        //display all over. 
        [stack removeAllObjects];
        [stack addObjectsFromArray:infixArray];
        
        NSString * infixArrayString = @"";
        
        for(NSUInteger i = 0; i < [stack count]; ++i)
        {
            //NSLog(@"Array value %@", (NSString *)[self.infixStack objectAtIndex:i]);
            
            infixArrayString = [[infixArrayString stringByAppendingString:@" "] stringByAppendingString:(NSString *)[stack objectAtIndex:i]];
        }
        
        //NSLog(@"Infix String = [%@]", infixArrayString);
        
        return infixArrayString;
    }
    
    return nil; 
}

//Add dictionaryWithObjectsAndKeys: for 3e
+ (BOOL) isVariable:(NSString *)operation
{
    NSLog(@"%g", operation);
    
    if([operation isEqualToString:@"x"] ||
       [operation isEqualToString:@"y"] ||
       [operation isEqualToString:@"a"] ||
       [operation isEqualToString:@"b"])
        return YES;
    
    return NO;
}

+ (NSSet *) variablesUsedInProgram:(id)program
{
    if([program isKindOfClass:[NSArray class]])
    {
        NSSet * variableSet = [[NSSet alloc] init];
        NSArray * stack = program;
        
        for(id object in stack) 
        {
            if([object isKindOfClass:[NSString class]])
                if(![CalculatorBrain isVariable:object])
                    [variableSet setByAddingObject:object];
        }
        
        if([variableSet count] > 0)
            return variableSet;
    }
    
    return nil;
}

+ (NSString *) isOperation:(NSString *)operation
{
    if([operation isEqualToString:@"+"] ||
       [operation isEqualToString:@"*"] ||
       [operation isEqualToString:@"-"] ||
       [operation isEqualToString:@"/"])
        return @"Two";

    if([operation isEqualToString:@"sin"] ||
       [operation isEqualToString:@"cos"] ||
       [operation isEqualToString:@"√"])
        return @"One";

    if([operation isEqualToString:@"+/-"])
        return @"Minus";
    
     if([operation isEqualToString:@"∏"])
        return @"Pi";
    
    return nil;
}

+ (void)    generateInfix:(NSMutableArray *)infixStackOutput
            usingInfixStack:(NSMutableArray *)infixStack
{
    if(![infixStack count])
        return;
    
    NSUInteger top = 0;
    
    id topOfStack = [infixStack objectAtIndex:top];
    
    if(topOfStack)
        [infixStack removeObjectAtIndex:top];
    else 
        return;
        
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        [infixStackOutput addObject:[NSString stringWithFormat:@"%g", [topOfStack doubleValue]]];
    }
    else if([topOfStack isKindOfClass:[NSString class]])
    {
        NSString * operation = [CalculatorBrain isOperation:topOfStack];
        
        if([operation isEqualToString:@"Pi"])
        {
            [infixStackOutput addObject:(NSString *)topOfStack];
        }
        else if([operation isEqualToString:@"Minus"])
        {
            NSString * operandOne = [infixStackOutput lastObject];
            
            if(operandOne)
            {
                [infixStackOutput removeLastObject];
                
                NSString * expression = [[[NSString stringWithFormat:@"-("] stringByAppendingString:operandOne] stringByAppendingString:@")"];
                
                [infixStackOutput addObject:expression];
            }
            else
                return;
        }
        else if([operation isEqualToString:@"One"])
        {
            NSString * operandOne = [infixStackOutput lastObject];
            
            if(operandOne)
            {
                [infixStackOutput removeLastObject];
                
                NSString * expression = [[[(NSString *)topOfStack stringByAppendingString:@"("] stringByAppendingString:operandOne] stringByAppendingString:@")"];
                
                [infixStackOutput addObject:expression];
            }
            else
                return;
        }
        else if([operation isEqualToString:@"Two"])
        {            
            NSString * operandOne = [infixStackOutput lastObject];
            
            if(operandOne)
            {                                  
                [infixStackOutput removeLastObject];
                
                NSString * operandTwo = [infixStackOutput lastObject];
            
                if(operandTwo)
                {
                    [infixStackOutput removeLastObject];
                
                   NSString * expression = [[[[@"(" stringByAppendingString:operandTwo] stringByAppendingString:(NSString *)topOfStack] stringByAppendingString:operandOne] stringByAppendingString:@")"];
                    
                    [infixStackOutput addObject:expression];
                }
                else
                    return;
            }
            else 
                return;
        }
        else
        {
            //Top of infixStackOutput has a previously evaluated infix expression. 
            [infixStackOutput addObject:(NSString *)topOfStack];
        }
    }
    
    [CalculatorBrain generateInfix:infixStackOutput usingInfixStack:infixStack];
}

+ (double) popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;   
    
    id topOfStack = [stack lastObject];
    
    if(topOfStack)
        [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        //perform operation details
        if([operation isEqualToString:@"+"])
        {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if([@"*" isEqualToString:operation])
        {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if([operation isEqualToString:@"-"])
        {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        }
        else if([operation isEqualToString:@"+/-"])
        {
            result = [self popOperandOffStack:stack];
            
            if(result != 0)
                result *= -1;
        }
        else if([operation isEqualToString:@"/"])
        {
            double divisor = [self popOperandOffStack:stack];
            
            if(divisor)
                result = [self popOperandOffStack:stack] / divisor;
        }
        else if([operation isEqualToString:@"sin"])
        {
            result = sin([self popOperandOffStack:stack]);
        }
        else if([operation isEqualToString:@"cos"])
        {
            result = cos([self popOperandOffStack:stack]);
        }
        else if([operation isEqualToString:@"√"])
        {
            result = sqrt([self popOperandOffStack:stack]);
        }
        else if([operation isEqualToString:@"∏"])
        {
            result = (double) 22/7;
        }
    }
    
    return result;
}

+ (double) runProgram:(id)program
{
    NSMutableArray * stack;
    
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    return [self popOperandOffStack:stack];
}

+ (double) runProgram:(id)program
           usingVariableValues:(NSMutableDictionary *)variableValues
{
    NSMutableArray * stack;
    
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
        
        for (NSUInteger i = 0; i < [stack count]; ++i) 
        {
            if([[stack objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                if([variableValues valueForKey:[stack objectAtIndex:i]])
                {
                    NSLog(@"Dictionary value is : %f", [[variableValues valueForKey:[stack objectAtIndex:i]] doubleValue]);

                    double operand = [[variableValues valueForKey:[stack objectAtIndex:i]] doubleValue];
                    
                    [stack replaceObjectAtIndex:i 
                                     withObject:[NSNumber numberWithDouble:operand]]; 
                }
            }
        }
    }

    return [self popOperandOffStack:stack];
}

+ (NSMutableArray *) runProgram:(id)program 
                     usingRange:(NSMutableArray *)variableValues
{
    NSMutableArray * resultValues = [[NSMutableArray alloc] init];
    
    if([program isKindOfClass:[NSArray class]])
    {
        for (NSUInteger i = 0; i < [variableValues count]; ++i) 
        {
            NSMutableArray * stack = [program mutableCopy];
            
            for (NSUInteger j = 0; j < [stack count]; ++j) 
            {
                if([[stack objectAtIndex:j] isKindOfClass:[NSString class]])
                {
                    [stack replaceObjectAtIndex:j 
                                     withObject:[variableValues objectAtIndex:i]];
                }
            }
            
            [resultValues addObject:[NSNumber numberWithDouble:[self popOperandOffStack:stack]]];
        }
    }
    
    return resultValues;
}

@end
