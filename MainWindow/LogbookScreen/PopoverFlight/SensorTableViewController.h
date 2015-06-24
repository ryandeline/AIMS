//
//  SensorTableViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/24/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sensor.h"

@protocol SensorSelectedDelegate <NSObject>
- (void)SensorSelected:(Sensor *)sensor;
@end

@interface SensorTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) id<SensorSelectedDelegate> delegate;

@end
