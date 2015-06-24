//
//  AirportTableViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/29/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Airport.h"

@protocol AirportSelectedDelegate <NSObject>
- (void)airportSelected:(Airport *)airport;
@end

@interface AirportTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) id<AirportSelectedDelegate> delegate;

@end
