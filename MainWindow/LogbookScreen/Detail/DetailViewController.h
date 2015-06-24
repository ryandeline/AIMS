//
//  DetailViewController.h
//  flightlog
//
//  Created by Chris Frederick on 9/23/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AircraftSelectionDelegate.h"
#import "NewFlightControllerViewController.h"
#import "NonFlightViewController.h"
#import "NewNoteViewController.h"
#import "MaintenanceEntryViewController.h"

@class DetailViewController;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, PFLogInViewControllerDelegate, AircraftSelectionDelegate, NewLogbookDelegate, NewNonFlightDelegate, NewNoteDelegate,MaintenanceEntryDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>

//@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, strong) UIPopoverController *logentryPopover;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *syncBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterControl;
@property (weak, nonatomic) IBOutlet UITableView *logbookTableView;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flightBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *maintainceBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nonFlightBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *noteBtn;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property NSString *tailNumber;
@property LogEntry *incompleteLogEntry;
@end
