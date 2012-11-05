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


//Redraw everytime data changes
- (void) refreshGraphView
{
    if(!(self.formula && self.graphView))
    {
        //@TODO - Remove later.
        //Clear user default settings
        
        return;
    }
    
    //Get back description of program. Save the scale and axisOrigin for each formula in NSUserDefaults
    NSString * formula = [CalculatorBrain descriptionOfProgram:[self.formula mutableCopy]];
    
    NSLog(@"Formula %@", formula);
    
    float scale = [[NSUserDefaults standardUserDefaults] floatForKey:[@"scale:" stringByAppendingString:formula]];
    
    if(scale)
        self.graphView.scale = scale;
    
    float xAxisOrigin = [[NSUserDefaults standardUserDefaults] floatForKey:[@"x:" stringByAppendingString:formula]];
    
    float yAxisOrigin = [[NSUserDefaults standardUserDefaults] floatForKey:[@"y:" stringByAppendingString:formula]];
    
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
    double result = [CalculatorBrain runProgram:self.formula 
                   usingVariableValues:[NSMutableDictionary 
                                        dictionaryWithObject:[NSNumber numberWithFloat:variable] forKey:@"x"]];
    
    return result;
}

- (void)    storeScale: (float)scale  
          forGraphView: (CalculatorGraphView *)sender
{
    NSString * formula = [CalculatorBrain descriptionOfProgram:[self.formula mutableCopy]];
    
    //Save the scale passed from the view in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setFloat:scale forKey:[@"scale:" stringByAppendingString:formula]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)    storeAxisOrigin: (CGPoint)axisOrigin    
               forGraphView: (CalculatorGraphView *) sender
{
    NSString * formula = [CalculatorBrain descriptionOfProgram:[self.formula mutableCopy]];
    
    //Save the axisOrigin passed from the view in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setFloat:axisOrigin.x forKey:[@"x:" stringByAppendingString:formula]];
    [[NSUserDefaults standardUserDefaults] setFloat:axisOrigin.y forKey:[@"y:" stringByAppendingString:formula]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
