//
//  ProjectTableViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjetSelectionDelegate.h"

@interface ProjectTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *fieldName;
@property (weak, nonatomic) id<ProjetSelectionDelegate> delegate;
@end
