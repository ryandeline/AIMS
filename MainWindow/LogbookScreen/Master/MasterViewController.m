//
//  MasterViewController.m
//  flightlog
//
//  Created by Chris Frederick on 9/23/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Aircraft.h"
#import "AircraftCell.h"
#import "SyncEngine.h"


@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTableSyncNotification:)
                                                 name:@"syncUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adminLoginNotification:)
                                                 name:@"adminLogin"
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _tailNumber = [defaults objectForKey:@"tailNumber"];
    if(_tailNumber == nil)
    {
        [self.cameraBtn setEnabled:NO];
    }
    
    //hide the cameraBtn
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) receiveTableSyncNotification:(NSNotification *) notification
{
    NSLog(@"%@ message=%@", [notification name], (NSString*)[notification object]);
    NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];

    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    AircraftCell *cell = (AircraftCell*)[self.tableView cellForRowAtIndexPath:ipath];
    if(cell)
        _tailNumber = [[NSString alloc] initWithString:cell.tailNumberLabel.text];
    else
        _tailNumber = nil;
    
}


- (void) adminLoginNotification:(NSNotification *) notification
{
    NSLog(@"%@ message=%@", [notification name], (NSString*)[notification object]);
    self.navigationItem.rightBarButtonItem = _cameraBtn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    ConfirmTailNumberViewController  *confirmController = [segue destinationViewController];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    AircraftCell *cell = (AircraftCell*)[self.tableView cellForRowAtIndexPath:selectedIndexPath];
    _tailNumber = [[NSString alloc] initWithString:cell.tailNumberLabel.text];
    confirmController.airplaneTail = _tailNumber;
    confirmController.delegate = self;
    
}

-(void) confirmTailNumberViewController:(ConfirmTailNumberViewController *)confirmTailNumberController didConfirm:(BOOL)confirmed
{
    if(confirmed == YES) {
        NSLog(@"tailNumber Confirmed");
        if (self.delegate != nil) {
            Aircraft *aircraft = (Aircraft *) [[self fetchedResultsController] objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
            [self.delegate aircraftSelectionChanged:aircraft];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        NSLog(@"tailNumber NOT confirmed");
        [self dismissViewControllerAnimated:YES completion: nil];
    }
    
    
}



- (IBAction)onSelectPicture:(id)sender {
    
    
    if ([_cameraPopover isPopoverVisible] == NO) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES){
            // Create image picker controller
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
            // Set source to the camera
            imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            
            // Delegate is self
            imagePicker.delegate = self;
            
            // Show image picker
            _cameraPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            _cameraPopover.delegate = self;
            _cameraPopover.popoverContentSize = CGSizeMake(320, 740);
            [_cameraPopover presentPopoverFromBarButtonItem:self.cameraBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [_cameraPopover dismissPopoverAnimated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [_cameraPopover dismissPopoverAnimated:YES];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(200, 200));
    [image drawInRect: CGRectMake(0, 0, 200, 200)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 1.0f);
    [self uploadImage:imageData tailNumber:_tailNumber];
}

- (void)uploadImage:(NSData *)imageData tailNumber:(NSString *)tailNumber {
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@.jpg",tailNumber];
    PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
    
    //HUD creation here
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_HUD];
    
    // Set determinate mode
    _HUD.mode = MBProgressHUDModeDeterminate;
    _HUD.delegate = self;
    _HUD.labelText = @"Uploading";
    [_HUD show:YES];

    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //Hide determinate HUD
            [_HUD hide:YES];
            
            // Show checkmark
            _HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_HUD];
            
            // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
            // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
            _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            
            // Set custom view mode
            _HUD.mode = MBProgressHUDModeCustomView;
            
            _HUD.delegate = self;
            
            
            // Create a PFObject around a PFFile and associate it with the current Aircraft
            PFObject *aircraft = [PFObject objectWithoutDataWithClassName:@"Aircraft" objectId:_parseObjectId];
            [aircraft setObject:imageFile forKey:@"imageFile"];
            [aircraft saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self refresh:nil];
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            [_HUD hide:YES];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        _HUD.progress = (float)percentDone/100;
    }];
}

-(void)refresh:(id)sender
{
    NSLog(@"Showing Refresh HUD");
    _refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_refreshHUD];
	
    // Register for HUD callbacks so we can remove it from the window at the right time
    _refreshHUD.delegate = self;
	
    // Show the HUD while the provided method executes in a new thread
    [_refreshHUD show:YES];
    
    [SyncEngine syncAircraftImages:^(NSError *error) {
        if (_refreshHUD) {
            [_refreshHUD hide:YES];
        }
        if(!error) {
            _refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_refreshHUD];
            
            // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
            // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
            _refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            
            // Set custom view mode
            _refreshHUD.mode = MBProgressHUDModeCustomView;
            
            _refreshHUD.delegate = self;

            NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];
            [self.tableView reloadData];
            [self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }];
    
            /*// The find succeeded.
            if (_refreshHUD) {
                [_refreshHUD hide:YES];
                
                _refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:_refreshHUD];
                
                // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
                // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
                _refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                
                // Set custom view mode
                _refreshHUD.mode = MBProgressHUDModeCustomView;
                
                _refreshHUD.delegate = self;
            }
            NSLog(@"Successfully retrieved %d photos.", objects.count);
            */
            
            // Let's save the file into Document folder.
            // You can also change this to your desktop for testing. (e.g. /Users/kiichi/Desktop/)
            // NSString *deskTopDir = @"/Users/kiichi/Desktop";
            
            //NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            /*
            // If you go to the folder below, you will find those pictures
            NSLog(@"%@",docDir);
            
            for(PFObject *eachObject in objects) {
                PFFile *theImage = [eachObject objectForKey:@"imageFile"];
                NSData *imageData = [theImage getData];
                UIImage *image = [UIImage imageWithData:imageData];
                NSString *jpgFilePath = [NSString stringWithFormat:@"%@/%@.jpg",docDir,[eachObject objectForKey:@"tailNumber"]];
                NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                [data2 writeToFile:jpgFilePath atomically:YES];
            }*/
            
        //} else {
            //[_refreshHUD hide:YES];
            
            // Log details of the failure
            //NSLog(@"Error: %@ %@", error, [error userInfo]);
        //}
    //}];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [hud removeFromSuperview];
	hud = nil;
}

/*- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"tailNumber"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}*/

#pragma mark - Table View

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tailNumber = [defaults objectForKey:@"tailNumber"];
    if([cell.textLabel.text isEqualToString:tailNumber])
    {
        [tableView selectRowAtIndexPath:indexPath
                               animated:NO
                         scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}


/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
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
}*/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView didSelectRowAtIndexPath");
    Aircraft *object = (Aircraft*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    _parseObjectId = object.objectId;
    _tailNumber = object.tailNumber;
    [self.cameraBtn setEnabled:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Aircraft" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tailNumber" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Aircraft"];
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
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
    [self.tableView endUpdates];
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
    AircraftCell *aCell = (AircraftCell*)cell;
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    aCell.tailNumberLabel.text = [[object valueForKey:@"tailNumber"] description];
    if([_tailNumber isEqualToString:aCell.tailNumberLabel.text]) {
         [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        _tailNumber = aCell.tailNumberLabel.text;
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpgFilePath = [NSString stringWithFormat:@"%@/%@.jpg",docDir,aCell.tailNumberLabel.text];
    UIImage *aircraftImage = [UIImage imageWithContentsOfFile:jpgFilePath];
    aCell.aircraftImageView.image = aircraftImage;
}

@end
