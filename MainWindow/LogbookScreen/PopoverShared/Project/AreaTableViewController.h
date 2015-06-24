//
//  AreaTableViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjetSelectionDelegate.h"

@interface AreaTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *projectName;
@property (strong, nonatomic) NSString *locationName;
@property (weak, nonatomic) id<ProjetSelectionDelegate> delegate;
@end
