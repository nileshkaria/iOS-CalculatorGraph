//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Nil on May/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import "CalculatorViewController.h"
#import "CalculatorGraphViewController.h"


@interface CalculatorViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userEnteredVariable;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSString * variableName;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize stackDisplay = _stackDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userEnteredVariable = _userEnteredVariable;
@synthesize brain = _brain;
@synthesize variableName = _variableName;

- (CalculatorBrain *) brain
{
    if(!_brain)
        _brain = [[CalculatorBrain alloc] init];
    
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    if(self.userIsInTheMiddleOfEnteringANumber)
    {
        self.display.text = [self.display.text stringByAppendingFormat:[sender currentTitle]];
        self.stackDisplay.text = [self.stackDisplay.text stringByAppendingFormat:[sender currentTitle]];
    }
    else
    {
        self.display.text = sender.currentTitle;
        self.stackDisplay.text = [[self.stackDisplay.text stringByAppendingFormat:@" "] stringByAppendingFormat:[sender currentTitle]];
        
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    
    //self.stackDisplay.text = [[self.stackDisplay.text stringByAppendingFormat:[sender currentTitle]] stringByAppendingFormat:@" "];
}

- (IBAction)variablePressed:(UIButton *)sender 
{
    if(self.userEnteredVariable)
        return;
    
    self.userEnteredVariable = YES;
    self.variableName = sender.currentTitle;
    
    self.display.text = sender.currentTitle;
    self.stackDisplay.text = [[self.stackDisplay.text stringByAppendingFormat:@" "] stringByAppendingFormat:[sender currentTitle]];
}

- (IBAction)equalPressed 
{
    //Variable cannot be assigned to another variable
    if([CalculatorBrain isVariable:self.display.text])
        return;
    
    //Reset values to allow input of variables and numbers later
    self.userEnteredVariable = NO;
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    [self.brain assignValueToVariable:self.display.text
                usingVariable:self.variableName];
}

- (IBAction)enterPressed 
{
    if([CalculatorBrain isVariable:self.display.text] == NO)
    {        
        [self.brain pushOperand:[self.display.text doubleValue]];
        
        //@TODO - Why the check here?
        if(self.userIsInTheMiddleOfEnteringANumber)
        {
            [self.brain pushFormula:[self.display.text doubleValue]];
            [self.brain pushInfix:[self.display.text doubleValue]];    
        }
        
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
    else
    {
        [self.brain pushVariable:self.display.text];
        self.userEnteredVariable = NO;
    }
}

- (IBAction)undoPressed 
{
    //If user is in the middle of typing a number, delete the previous digit
    if(self.userIsInTheMiddleOfEnteringANumber)
    {
        if([CalculatorBrain isVariable:self.display.text] == NO)
        {
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
            
            self.stackDisplay.text = [self.stackDisplay.text substringToIndex:[self.stackDisplay.text length] - 1];
            
            if([self.display.text length] == 0)
                self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
    else
    {
    
        self.display.text = [NSString stringWithFormat:@"%g", [self.brain removeLastObjectAndPerformOperation]];
    
        //[self enterPressed]; needed?
        
        self.stackDisplay.text = [self.brain descriptionOfTopOfStack];
    }
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    //If user is in the middle of typing a number, implicitly press Enter
    if(self.userIsInTheMiddleOfEnteringANumber ||
       self.userEnteredVariable)
        [self enterPressed];
    
    self.display.text = [NSString stringWithFormat:@"%g", [self.brain performOperation:[sender currentTitle]]];
    
    //The operation for pi is incorrect. If the value is stored on the stack, 
    //it will not be popped out and will be used by succeeding operation.
    if([[sender currentTitle] isEqualToString:@"sin"] ||
       [[sender currentTitle] isEqualToString:@"cos"] ||
       [[sender currentTitle] isEqualToString:@"√"]   ||
       [[sender currentTitle] isEqualToString:@"+/-"] ||
       [[sender currentTitle] isEqualToString:@"∏"])
        [self enterPressed];
    
    //self.stackDisplay.text = [[self.stackDisplay.text stringByAppendingFormat:@" "] stringByAppendingFormat:[sender currentTitle]];
    
    //NSLog(@"Infix [%@]", [self.brain descriptionOfTopOfStack]);
    
    self.stackDisplay.text = [self.brain descriptionOfTopOfStack];
}


 //NOTE - Add Test f button if required
- (IBAction)testFormula 
{
    self.display.text = [NSString stringWithFormat:@"%g", [self.brain performOperationUsingVariables]];
}

- (IBAction)decimalPressed:(UIButton *)sender 
{
    if([CalculatorBrain isVariable:self.display.text] == NO)
    {
        //If we already have a decimal in the result, do not reset decimal pressed
        NSRange range = [self.display.text rangeOfString:@"."];
        if(range.location == NSNotFound)
        {
            self.display.text = [self.display.text stringByAppendingString:@"."];
            self.stackDisplay.text = [self.stackDisplay.text stringByAppendingFormat:@"."];
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
    }
}

- (IBAction)clearPressed 
{
    [self.brain clearStack];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userEnteredVariable = NO;
    
    self.display.text = @"0";
    self.stackDisplay.text= @"";
}

- (IBAction)generateGraph 
{
    [self performSegueWithIdentifier:@"DrawGraph" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DrawGraph"]) 
    {
        //@NOTE - Fill initial model of CalculatorGraphViewController here.
        [segue.destinationViewController setFormula:[self.brain.formula mutableCopy]];
    }
}


- (void)viewDidUnload {
    [self setStackDisplay:nil];
    [super viewDidUnload];
}
@end
