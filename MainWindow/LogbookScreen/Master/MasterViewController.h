//
//  MasterViewController.h
//  flightlog
//
//  Created by Chris Frederick on 9/23/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "ConfirmTailNumberViewController.h"
#import "AircraftSelectionDelegate.h"
#import "MBProgressHUD.h"
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, ConfirmTailNumberDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, UIPopoverControllerDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) id<AircraftSelectionDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraBtn;
@property (strong, nonatomic) UIPopoverController *cameraPopover;
@property MBProgressHUD *HUD;
@property MBProgressHUD *refreshHUD;
@property NSString *tailNumber;
@property NSString *parseObjectId;

@end
