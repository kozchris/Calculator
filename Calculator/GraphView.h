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
-(NSString*)getProgramDescription:(GraphView*) sender;
-(float)getYforX:(float) x;
@end

@interface GraphView : UIView

@property (nonatomic) NSString * programDescription;

@property (nonatomic,weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
