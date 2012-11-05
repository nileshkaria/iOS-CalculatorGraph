//
//  CalculatorGraphView.h
//  CalculatorGraph
//
//  Created by Nilesh Karia on Oct/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//Forward declaration
@class CalculatorGraphView;

@protocol GraphViewDataSource

- (double)  functionValueForVariable:   (float)variable         forGraphView: (CalculatorGraphView *)sender;
- (void)    storeScale:                 (float)scale            forGraphView: (CalculatorGraphView *)sender;  
- (void)    storeAxisOrigin:            (CGPoint)axisOrigin     forGraphView: (CalculatorGraphView *) sender; 

@end

@interface CalculatorGraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint axisOrigin;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
