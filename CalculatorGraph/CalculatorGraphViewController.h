//
//  CalculatorGraphViewController.h
//  CalculatorGraph
//
//  Created by Nilesh Karia on Oct/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorGraphViewController : UIViewController

//@property (nonatomic) NSMutableArray stack;

@property (nonatomic, strong) id formula;
@property (nonatomic, strong) id infix;
@property (nonatomic, weak) IBOutlet UILabel *display;

@end
