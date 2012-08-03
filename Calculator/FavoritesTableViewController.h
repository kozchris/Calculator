//
//  FavoritesTableViewController.h
//  Calculator
//
//  Created by Christopher Snyder on 7/26/12.
//  Copyright (c) 2012 T-VEC Technolgies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FavoritesTableViewController;

@protocol FavoritesTableViewControllerDelegate <NSObject>
@optional
-(void) favoritesTableViewController:(FavoritesTableViewController*)sender choseProgram:(id)program;

@optional
-(void) favoritesTableViewController:(FavoritesTableViewController *)sender deletedProgram:(id)program;

@end

@interface FavoritesTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *programs; //of calculator brain programs

@property (nonatomic, weak) id <FavoritesTableViewControllerDelegate> delegate;

@end
