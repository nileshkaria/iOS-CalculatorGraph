//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Nil on May/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject


- (void)   clearStack;
- (void)   pushOperand:(double) operand;
- (void)   pushFormula:(double) operand;
- (void)   pushInfix:(double) operand;
- (void)   pushVariable:(NSString *) operand;

- (void)    assignValueToVariable:(id)value
                    usingVariable:(NSString *)variable;

- (double) popOperand;
- (double) performOperationUsingVariables;
- (double) removeLastObjectAndPerformOperation;
- (double) performOperation:(NSString *)operation;

- (NSString *) descriptionOfTopOfStack;

@property (readonly) id program;
@property (readonly) id infix;
@property (readonly) id formula;

+ (BOOL)        isVariable:(NSString *)operand;

+ (NSSet *)     variablesUsedInProgram:(id)program;
+ (NSString *)  isOperation:(NSString *)operation;
+ (NSString *)  descriptionOfProgram:(NSMutableArray *)stack;

+ (void)        generateInfix:(NSMutableArray *)infixStackOutput
                usingInfixStack:(NSMutableArray *)infixStack;

+ (double)              runProgram:(id)program;

+ (double)              runProgram:(id)program
                usingVariableValues:(NSMutableDictionary *)variableValues;

+ (NSMutableArray *)   runProgram:(id)program
                       usingRange:(NSMutableArray *)variableValues;
@end
