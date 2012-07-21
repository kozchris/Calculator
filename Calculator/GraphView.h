//
//  GraphView.h
//  Calculator
//
//  Created by Chris Snyder on 7/14/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource <NSObject>
-(NSString*)getProgramDescription:(GraphView*) sender withProgramNumber:(int) programNumber;
-(float)getYforX:(float) x withProgramNumber:(int) programNumber;
-(int)getProgramCount;
@end

@interface GraphView : UIView

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat scale;

@property (nonatomic) NSString * programDescription;

@property (nonatomic,weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
