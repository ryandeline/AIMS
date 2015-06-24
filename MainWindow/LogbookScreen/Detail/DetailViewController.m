//
//  DetailViewController.m
//  flightlog
//
//  Created by Chris Frederick on 9/23/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "DetailViewController.h"
#import "Parse/Parse.h"
#import "SyncEngine.h"
#import "LogEntry.h"
#import "Crew.h"
#import "LogbookCell.h"
#import "NonflightCell.h"
#import "NoteCell.h"
#import "MaintenanceCell.h"
#import "MasterViewController.h"

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
    self.logbookTableView.delegate = self;
    self.logbookTableView.dataSource = self;
    
    // New child context
    _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _backgroundContext.parentContext = _managedObjectContext;
    
    // set our current plane to the default.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _tailNumber = [defaults objectForKey:@"tailNumber"];
    self.detailDescriptionLabel.text = _tailNumber;
    _incompleteLogEntry = nil;
    if(_tailNumber == nil)
    {
        self.detailDescriptionLabel.text = @"No Aircraft Selected";
        [_flightBtn setEnabled:NO];
        [_noteBtn setEnabled:NO];
        [_nonFlightBtn setEnabled:NO];
        [_maintainceBtn setEnabled:NO];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"will rotate");

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_tableView reloadData];
    if(_logentryPopover)
        [_logentryPopover dismissPopoverAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Value: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"NewLogEntry"]) {
        self.logentryPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.logentryPopover.delegate = self;
        CGSize size;
        size.height = 740.0f;
        size.width = 320.0f;
        [self.logentryPopover setPopoverContentSize:size animated:NO];
        
        UINavigationController *navController = [segue destinationViewController];
        NewFlightControllerViewController  *newFlightLogController = (NewFlightControllerViewController*)[navController topViewController];
        newFlightLogController.delegate = self;
        [newFlightLogController setManagedObjectContext:_backgroundContext];
        
        if(_incompleteLogEntry) {
            [newFlightLogController setupForLogEntry:_incompleteLogEntry];
        } else {
            //Create a newlogEntry in the background context.
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:_backgroundContext];
            LogEntry *logEntry = [[LogEntry alloc] initWithEntity:entity insertIntoManagedObjectContext:_backgroundContext];
            
            //Set the default values of the logEntry based on the most recent entry for this aircraft.
            LogEntry *latestLogEntry = [LogEntry getLatestLogEntryForAircraft:_tailNumber inManagedObjectContext:_backgroundContext];
            if(latestLogEntry) {
                logEntry.toICAO = latestLogEntry.toICAO;
                logEntry.fromICAO = latestLogEntry.fromICAO;
                logEntry.pilot = latestLogEntry.pilot;
                logEntry.pilot2 = latestLogEntry.pilot2;
                logEntry.pilot3 = latestLogEntry.pilot3;
                logEntry.pilot4 = latestLogEntry.pilot4;
                logEntry.hobbsStart = latestLogEntry.hobbsEnd;
                logEntry.hobbsEnd = logEntry.hobbsStart;
                logEntry.tachStart = latestLogEntry.tachEnd;
                logEntry.tachEnd = logEntry.tachStart;
                logEntry.hobbsDuration = [[NSNumber alloc] initWithInt:0];
                logEntry.tachDuration = [[NSNumber alloc] initWithInt:0];
                logEntry.sensor = latestLogEntry.sensor;
                logEntry.project = latestLogEntry.project;
            }
            
            [logEntry setTailNumber:_tailNumber];
            [logEntry setLogType:@"flight"];
            [logEntry setLogDate:[NSDate date]];
            [logEntry setSyncInd:[NSNumber numberWithBool:NO]];
            [newFlightLogController setupForLogEntry:logEntry];
            _incompleteLogEntry = logEntry;
        }
        
    }
    else if([segue.identifier isEqualToString:@"NewNonFlightEvent"]) {
        self.logentryPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.logentryPopover.delegate = self;
        UINavigationController *navController = [segue destinationViewController];
        NonFlightViewController  *nonFlightController = (NonFlightViewController*)[navController topViewController];
        nonFlightController.delegate = self;

        CGSize size;
        size.height = 450.0f;
        size.width = 320.0f;
        [self.logentryPopover setPopoverContentSize:size animated:NO];
    }
    else if([segue.identifier isEqualToString:@"NewMaintenanceEvent"]) {
        self.logentryPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.logentryPopover.delegate = self;
        UINavigationController *navController = [segue destinationViewController];
        MaintenanceEntryViewController  *controller = (MaintenanceEntryViewController*)[navController topViewController];
        CGSize size;
        size.height = 500.0f;
        size.width = 320.0f;
        [self.logentryPopover setPopoverContentSize:size animated:NO];
        
        //We need to find the latest log entry so that we can get the default tach hours.
        LogEntry *latestEntry = [LogEntry getLatestLogEntryForAircraft:_tailNumber inManagedObjectContext:_managedObjectContext];
        
        controller.tachHours = latestEntry.tachEnd;
        controller.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"NewNoteEntry"]) {
        self.logentryPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.logentryPopover.delegate = self;
        UINavigationController *navController = [segue destinationViewController];
        NewNoteViewController  *controler = (NewNoteViewController*)[navController topViewController];
        controler.delegate = self;
        CGSize size;
        size.height = 450.0f;
        size.width = 320.0f;
        [self.logentryPopover setPopoverContentSize:size animated:NO];
    }
    else if([segue.identifier isEqualToString:@"cellNonFlightPopOver"]) {
    
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.logentryPopover isPopoverVisible]) {
        [self.logentryPopover dismissPopoverAnimated:YES];
        return NO;
    }
    
    UITableViewCell *cell = (UITableViewCell*)sender;
    if([cell isKindOfClass:[LogbookCell class]])
    {
        LogbookCell *lc = (LogbookCell*)cell;
        if(lc.syncBtn.isHidden) {
            return NO;
        }
    }
    return YES;
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if(_logentryPopover == popoverController)
    {
        _logentryPopover = nil;
        NSLog(@"Dismissed logentry Popover");
    }
    else {
        NSLog(@"Dismissed some other popover");
    }
}

- (IBAction)syncAction:(id)sender {
    
    //make sure the use is logged out
    [PFUser logOut];
    
    //dismiss the pop-over if it exists.
    if(self.logentryPopover)
        [self.logentryPopover dismissPopoverAnimated:YES];
    
    //abandon any incomplete log entry
    if(_incompleteLogEntry)
    {
        [_backgroundContext deleteObject:_incompleteLogEntry];
        _incompleteLogEntry = nil;
    }
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsPasswordForgotten | PFLogInFieldsLogInButton | PFLogInFieldsDismissButton];
        logInViewController.logInView.logo = nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        logInViewController.logInView.usernameField.text =[defaults objectForKey:@"username"];
       
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:^{ [logInViewController.logInView.passwordField becomeFirstResponder];}];
        
    }
    
}

# pragma mark - handle notifications of new log book entries to insert into core data.
- (void)newLogbookEntry:(LogEntry *)logEntry {
    
    [_backgroundContext performBlock:^{
        // push to parent
        NSError *error;
        if (![_backgroundContext save:&error])
        {
            NSLog(@"Failed to save background context");
        }
        
        // save parent to disk asynchronously
        [_managedObjectContext performBlock:^{
            NSError *error;
            if (![_managedObjectContext save:&error])
            {
                NSLog(@"Failed to save main context");
            }
            _incompleteLogEntry = nil;
        }];
    }];
    
    [self.logentryPopover dismissPopoverAnimated:YES];
}

# pragma mark - handle notifications of new non flight entries and insert into core data.
- (void) newNonFlightEntryForDate:(NSDate *)date withReason:(NSString *)reason andComment:(NSString *)comment {
    
    NSLog(@"NonFlight reason: %@", reason);
    
    //Create our newlogEntry in the background context.
    NSError *error = nil;
    NSEntityDescription *logEntity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:_managedObjectContext];
    LogEntry *logEntry = [[LogEntry alloc] initWithEntity:logEntity insertIntoManagedObjectContext:_managedObjectContext];
    
    [logEntry setLogType:@"nonflight"];
    [logEntry setLogDate:date];
    [logEntry setComment:comment];
    [logEntry setNonFlightReason:reason];
    [logEntry setSyncInd:[NSNumber numberWithBool:NO]];
    [logEntry setTailNumber:_tailNumber];
    
    if (![_managedObjectContext save:&error])
    {
        NSLog(@"Failed to save main context");
    }
    
    if(self.logentryPopover)
        [self.logentryPopover dismissPopoverAnimated:YES];
}

# pragma mark - handle notifications of new Maintenance entries and insert into core data.
-(void) newMaintenanceEntry:(NSDate *)date withType:(NSString *)maintenanceType tachHours:(NSNumber *)tachHours andComment:(NSString *)comment {
    NSLog(@"newMaintenanceEntry maintenanceType: %@", maintenanceType);
    
    NSError *error = nil;
    NSEntityDescription *logEntity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:_managedObjectContext];
    LogEntry *logEntry = [[LogEntry alloc] initWithEntity:logEntity insertIntoManagedObjectContext:_managedObjectContext];
    
    [logEntry setLogType:@"maintenance"];
    [logEntry setLogDate:date];
    [logEntry setComment:comment];
    [logEntry setMaintenanceType:maintenanceType];
    [logEntry setSyncInd:[NSNumber numberWithBool:NO]];
    [logEntry setTachEnd:tachHours];
    [logEntry setTailNumber:_tailNumber];
    
    if (![_managedObjectContext save:&error])
    {
        NSLog(@"Failed to save main context");
    }
    
    if(self.logentryPopover)
        [self.logentryPopover dismissPopoverAnimated:YES];
}

# pragma mark - handle notifications of new note entries and insert into core data.

- (void) newNoteForDate:(NSDate *)date withComment:(NSString *)comment  {
    NSLog(@"New Note: %@", comment);
    
    NSError *error = nil;

    //Create our newlogEntry in the background context.
    NSEntityDescription *logEntity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:_managedObjectContext];
    LogEntry *logEntry = [[LogEntry alloc] initWithEntity:logEntity insertIntoManagedObjectContext:_managedObjectContext];
    
    [logEntry setLogType:@"note"];
    [logEntry setLogDate:date];
    [logEntry setComment:comment];
    [logEntry setSyncInd:[NSNumber numberWithBool:NO]];
    [logEntry setTailNumber:_tailNumber];
    
    if (![_managedObjectContext save:&error])
    {
        NSLog(@"Failed to save main context");
    }
    
    if(self.logentryPopover)
        [self.logentryPopover dismissPopoverAnimated:YES];
}
#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username forKey:@"username"];
        [defaults synchronize];
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    NSString *admin = (NSString*)[user valueForKey:@"admin"];
    if([admin isEqualToString:@"Y"]) {
        NSLog(@"Admin just logged in.. sssshhhazz!");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"adminLogin" object:@"adminlogin"];
    }
        
    SyncEngine *syncEngine = [[SyncEngine alloc] init];
    [syncEngine registerNSManagedObjectClassToSync:[Aircraft class]];
    [syncEngine registerNSManagedObjectClassToSync:[Project class]];
    [syncEngine registerNSManagedObjectClassToSync:[Sensor class]];
    [syncEngine registerNSManagedObjectClassToSync:[Crew class]];
    [syncEngine registerNSManagedObjectClassToSync:[Airport class]];
    [syncEngine startSyncForTailNumber:_tailNumber withManagedObjectContext:_managedObjectContext viewController:self.view];

    //[[[UIAlertView alloc] initWithTitle:@"Sync Complete" message:@"You did it!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    
    // really we want to wait until the sync is complete before dismissing view controller.
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in... Sync Aborted");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Handle changes in the aircraft we are viewing from the master controller
-(void)aircraftSelectionChanged:(Aircraft *)currSelection
{
    self.detailDescriptionLabel.text = currSelection.tailNumber;
    _tailNumber = currSelection.tailNumber;
    _flightBtn.enabled = YES;
    _nonFlightBtn.enabled = YES;
    _maintainceBtn.enabled = YES;
    _noteBtn.enabled = YES;
    
    //abandon incomplete log entries for another aircraft
    if(_incompleteLogEntry)
    {
        [_backgroundContext deleteObject:_incompleteLogEntry];
        _incompleteLogEntry = nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_tailNumber forKey:@"tailNumber"];
    [defaults synchronize];
    
    [self changeLogbookPredicateForTailNumber:_tailNumber withLogType:[self getFilteredLogType]];
    
    if(self.popover != nil)
        [self.popover dismissPopoverAnimated:YES];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Aircraft";
    
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    //[items removeObjectAtIndex:0]; //cationary removal -- attempt to fix bug ryan sees.
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popover = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popover = nil;
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = nil;
    if([log.logType isEqualToString:@"flight"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LogbookCell" forIndexPath:indexPath];
    }
    else if([log.logType isEqualToString:@"nonflight"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NonflightCell" forIndexPath:indexPath];
    }
    else if([log.logType isEqualToString:@"maintenance"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MaintenanceCell" forIndexPath:indexPath];
    }
    else if([log.logType isEqualToString:@"note"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    return ![log.syncInd boolValue];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
         [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
         
         NSError *error = nil;
         if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
             abort();
         }
     }
 }

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                 bundle:nil];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    /*if([cell isKindOfClass:[MaintenanceCell class]])
    {
        
        UINavigationController *detailController = [sb instantiateViewControllerWithIdentifier:@"maintanceNavController"];
        
        self.logentryPopover = [[UIPopoverController alloc] initWithContentViewController:detailController];
        [_logentryPopover.contentViewController.view setUserInteractionEnabled:NO];
        //MaintenanceEntryViewController *vc = (MaintenanceEntryViewController*)self.logentryPopover.contentViewController;
//        [vc.view setUserInteractionEnabled:NO];
        self.logentryPopover.delegate = self;
        self.logentryPopover.popoverContentSize = CGSizeMake(320, 500);
        [self.logentryPopover presentPopoverFromRect:cell.bounds inView:cell.contentView
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];
    }
    else*/
    if([cell isKindOfClass:[LogbookCell class]]) {
        UINavigationController *detailController = [sb instantiateViewControllerWithIdentifier:@"newFlightNavController"];
        
        self.logentryPopover = [[UIPopoverController alloc] initWithContentViewController:detailController];
        self.logentryPopover.delegate = self;
        self.logentryPopover.popoverContentSize = CGSizeMake(320, 740);
        CGRect r = cell.bounds;
        r.size.width = r.size.width*.20;
        [self.logentryPopover presentPopoverFromRect:r inView:cell.contentView
                            permittedArrowDirections:UIPopoverArrowDirectionLeft
                                            animated:YES];
        
        LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        NewFlightControllerViewController *vc = (NewFlightControllerViewController*) [detailController topViewController];
        [vc setupForLogEntry:log];
        [vc setManagedObjectContext:_managedObjectContext];
        
        if(log.syncInd.boolValue == YES) {
            [vc setTitle:@"View Flight"];
            [vc setReadOnly:YES];
        } else {
            [vc setTitle:@"Edit Flight"];
            [vc setReadOnly:NO];
        }
        
        [vc.navigationItem setRightBarButtonItem:nil];
    }
    else {
        //if([cell isKindOfClass:[NoteCell class]]) 
        CommentsViewController *detailController = [sb instantiateViewControllerWithIdentifier:@"commentsController"];
        
        self.logentryPopover = [[UIPopoverController alloc] initWithContentViewController:detailController];
        self.logentryPopover.delegate = self;
        
        CGSize size;
        size.height = 345.0f;
        size.width = 320.0f;
        
        self.logentryPopover.popoverContentSize = size;
        CGRect r = cell.bounds;
        r.size.width = r.size.width*.20;
        [self.logentryPopover presentPopoverFromRect:r inView:cell.contentView
                            permittedArrowDirections:UIPopoverArrowDirectionLeft
                                            animated:YES];
        LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [detailController setTitle:@"View Note"];
        [detailController setReadOnly:YES];
        detailController.initialComment = log.comment;
        detailController.textView.text = log.comment;
        detailController.textView.editable = NO;         
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.row == 0) {
    //    return 100;
    //} else {
    //    return 60;
    //}
    return 88;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Sort by LogDate Desc
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"logDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Only show records for the currently selected tailNumber
    NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"tailNumber = %@",_tailNumber];
    fetchRequest.predicate = newPredicate;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    // set cacheName to nil and don't set a delegate to disable change tracking and allow us to use the NSDictionaryResultType
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (NSString*) getFilteredLogType {
    switch(_filterControl.selectedSegmentIndex) {
        case 0: //ALL
            return nil;
        case 1: //Flights
            return @"flight";
        case 2: //Maint.
            return @"maintenance";
        case 3: //Notes
            return @"note";
        case 4: //Non-Flight
            return @"nonflight";
    }
    return nil;
}

- (IBAction)segmentChanged:(id)sender {
    [self changeLogbookPredicateForTailNumber:_tailNumber withLogType:[self getFilteredLogType]];
}

// The method to change the predicate of the FRC
- (void)changeLogbookPredicateForTailNumber:(NSString*)tailNumber withLogType:(NSString*)logType
{
    NSError *error;
    if (tailNumber.length > 0) {
        NSPredicate *newPredicate = nil;
        if(logType.length > 0) {
            newPredicate = [NSPredicate predicateWithFormat:@"tailNumber = %@ and logType = %@",tailNumber, logType];
        } else {
            newPredicate = [NSPredicate predicateWithFormat:@"tailNumber = %@",tailNumber];
        }
        _fetchedResultsController.fetchRequest.predicate = newPredicate;
    } else {
        _fetchedResultsController.fetchRequest.predicate = nil;
    }
    
    [self.fetchedResultsController performFetch:&error];
    [_logbookTableView reloadData];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.logbookTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.logbookTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.logbookTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.logbookTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.logbookTableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[LogbookCell class]])
    {
        
        LogbookCell *logCell = (LogbookCell*) cell;
        LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Log Date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        logCell.dateLabel.text = [formatter stringFromDate:log.logDate];
        
        //Project
        logCell.projectLabel.text = log.project.projectName;
        logCell.projectLabel.text = [[NSString alloc] initWithFormat:@"%@\n%@\n%@", log.project.projectName, log.project.locationName, log.project.areaName];
        //logCell.areaLabel.text = log.project.areaName;
        //logCell.locationLabel.text = log.project.locationName;
        
        //Hours
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMaximumFractionDigits:1];
        //logCell.hobbsStartLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.hobbsStart]];
         logCell.hobbsEndLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.hobbsEnd]];
        //logCell.hobbsDurationLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.hobbsDuration]];
        // logCell.tachStartLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.tachStart]];
         logCell.tachEndLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.tachEnd]];
        //logCell.tachDurationLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.tachDuration]];
        
        /*logCell.tachBtnLabel.titleLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.tachEnd]];
        CGSize requiredSize = [[logCell.tachBtnLabel titleForState:UIControlStateNormal] sizeWithFont:logCell.tachBtnLabel.titleLabel.font];
        CGRect frame = logCell.tachBtnLabel.titleLabel.frame;
        frame.size = requiredSize;
        logCell.tachBtnLabel.titleLabel.frame = frame;
        
        logCell.hobbsBtnLabel.titleLabel.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.hobbsEnd]];
        */
    

        
        //comment
        logCell.commentLabel.text = log.comment;
        
        //pilot
        //logCell.pilotLabel.text = log.pilot.crewName;
        
        //route
        logCell.routeLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@\n%@\n%@", log.fromICAO, log.toICAO, log.pilot.crewName, log.sensor.sensorName];
        
        //sync button
        logCell.syncBtn.hidden = [log.syncInd boolValue];
    }
    else if([cell isKindOfClass:[NonflightCell class]] )
    {
        NonflightCell *nonflightCell = (NonflightCell*) cell;
        LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Log Date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        nonflightCell.dateLabel.text = [formatter stringFromDate:log.logDate];
        
        //reason
        nonflightCell.reasonLabel.text = log.nonFlightReason;
        
        //comment
        nonflightCell.commentLabel.text = log.comment;
        
        //sync button
        nonflightCell.syncImage.hidden = [log.syncInd boolValue];
      
    }
    else if([cell isKindOfClass:[MaintenanceCell class]])
    {
        MaintenanceCell *maintenanceCell = (MaintenanceCell*) cell;
        LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Log Date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        maintenanceCell.dateLabel.text = [formatter stringFromDate:log.logDate];
        
        //maintenance type
        maintenanceCell.maintenanceTypeLabel.text = log.maintenanceType;
        
        //comment
        maintenanceCell.commentLabel.text = log.comment;
        
        //sync button
        maintenanceCell.syncImage.hidden = [log.syncInd boolValue];
        
        // tach hours
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMaximumFractionDigits:1];
        maintenanceCell.tachHours.text = [[NSString alloc] initWithFormat:@"%@",[numberFormatter stringFromNumber:log.tachEnd]];
    }
    else if([cell isKindOfClass:[NoteCell class]] )
    {
        NoteCell *noteCell = (NoteCell*) cell;
        LogEntry *log = (LogEntry*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Log Date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        noteCell.dateLabel.text = [formatter stringFromDate:log.logDate];
        
        //comment
        noteCell.commentLabel.text = log.comment;
        
        //sync button
        noteCell.btnImage.hidden = [log.syncInd boolValue];
        
    }
}



@end
