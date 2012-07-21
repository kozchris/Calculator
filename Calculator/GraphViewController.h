//
//  GraphViewController.h
//  Calculator
//
//  Created by Chris Snyder on 7/14/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) NSArray *programs;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
