//
//  CalculatorGraphViewController.m
//  CalculatorGraph
//
//  Created by Nilesh Karia on Oct/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import "CalculatorGraphViewController.h"
#import "CalculatorGraphView.h"

@interface CalculatorGraphViewController() <GraphViewDataSource>

@property (nonatomic, weak) IBOutlet CalculatorGraphView * graphView;

//TODO - Add data which tracks value to be put on graph

@end

@implementation CalculatorGraphViewController

@synthesize graphView  = _graphView;
@synthesize formula    = _formula; 
@synthesize infix      = _infix;
@synthesize display    = _display;

//Redraw everytime data changes
- (void) refreshGraphView
{
    if(!(self.formula && self.infix && self.graphView))
    {
        //@TODO - Remove later.
        //Clear user default settings
        
        return;
    }
    
    //Get back description of program. Save the scale and axisOrigin for each equation in NSUserDefaults
    NSString * infix = [CalculatorBrain descriptionOfProgram:[self.infix mutableCopy]];
    
    self.display.text = infix;
    
    NSLog(@"Equation %@", infix );
    
    float scale = [[NSUserDefaults standardUserDefaults] floatForKey:[@"scale:" stringByAppendingString:infix]];
    
    if(scale)
        self.graphView.scale = scale;
    
    float xAxisOrigin = [[NSUserDefaults standardUserDefaults] floatForKey:[@"x:" stringByAppendingString:infix]];
    
    float yAxisOrigin = [[NSUserDefaults standardUserDefaults] floatForKey:[@"y:" stringByAppendingString:infix]];
    
    if(xAxisOrigin && yAxisOrigin)
    {
        CGPoint axisOrigin;
        axisOrigin.x = xAxisOrigin;
        axisOrigin.y = yAxisOrigin;
        
        self.graphView.axisOrigin = axisOrigin;
    }
    
    [self.graphView setNeedsDisplay];
}

- (void) setFormula:(id)formula
{
    NSMutableArray * stack = formula;
    
    for(NSUInteger i = 0; i < [stack count]; ++i)
    {
        NSLog(@"Array value %@", (NSString *)[stack objectAtIndex:i]);
    }
    
    if(_formula != formula)
    {
        _formula = formula;
    
        //Data changed. Redraw.
        //[self.graphView setNeedsDisplay];
        [self refreshGraphView];
    }
}

- (void) setInfix:(id)infix
{
    //No need to redraw as we will redraw with change of formula
    _infix = infix;
}

- (void) setGraphView:(CalculatorGraphView *)graphView
{
    _graphView = graphView;
    
    //Set graphView delegate
    self.graphView.dataSource = self;
    
    //Who will handle this gesture? The graphView will, which is passed into initWithTarget. NOTE - self is NOT passed to pan:
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc]   initWithTarget:self.graphView action:@selector(pan:)]];
 
    //Data changed. Redraw.
    //[self.graphView setNeedsDisplay];
    [self refreshGraphView];
}

- (double)  functionValueForVariable: (float)variable         
                        forGraphView: (CalculatorGraphView *)sender
{
    // Here is where the calculator brains function executes the formula stack
    return [CalculatorBrain runProgram:self.formula 
                   usingVariableValues:[NSMutableDictionary 
                                        dictionaryWithObject:[NSNumber numberWithFloat:variable] forKey:@"x"]];    
}

-(NSMutableArray *) functionValuesForVariableArray:(NSMutableArray *)variables 
                                      forGraphView:(CalculatorGraphView *)sender
{
    return [CalculatorBrain runProgram:self.formula usingRange:variables];
}

- (void)    storeScale: (float)scale  
          forGraphView: (CalculatorGraphView *)sender
{
    NSString * infix = [CalculatorBrain descriptionOfProgram:[self.infix mutableCopy]];
    
    //Save the scale passed from the view in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setFloat:scale forKey:[@"scale:" stringByAppendingString:infix]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)    storeAxisOrigin: (CGPoint)axisOrigin    
               forGraphView: (CalculatorGraphView *) sender
{
    NSString * infix = [CalculatorBrain descriptionOfProgram:[self.infix mutableCopy]];
    
    //Save the axisOrigin passed from the view in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setFloat:axisOrigin.x forKey:[@"x:" stringByAppendingString:infix]];
    [[NSUserDefaults standardUserDefaults] setFloat:axisOrigin.y forKey:[@"y:" stringByAppendingString:infix]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


//@TODO - Fix this.
- (IBAction)resetUserDefaults 
{
    CGPoint axisOrigin;
    axisOrigin.x = 0;
    axisOrigin.y = 0;
    
    [self storeAxisOrigin:axisOrigin forGraphView:self.graphView];
    
    [self storeScale:0.0 forGraphView:self.graphView];

    [self refreshGraphView];
}

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

*/

@end
