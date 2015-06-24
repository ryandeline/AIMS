//
//  NewFlightControllerViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/4/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import "HobbsTableViewController.h"
#import "ProjectTableViewController.h"
#import "ProjetSelectionDelegate.h"
#import "SensorTableViewController.h"
#import "CrewTableViewController.h"
#import "AirportTableViewController.h"
#import "CommentsViewController.h"
#import "LogEntry.h"

@protocol NewLogbookDelegate <NSObject>
- (void)newLogbookEntry:(LogEntry *)logEntry;
@end

@interface NewFlightControllerViewController : UITableViewController <DatePickerDelegate, MeterDataEnteredDelegate,ProjetSelectionDelegate, SensorSelectedDelegate, CrewSelectedDelegate, AirportSelectedDelegate, CommentEditedDelegate>

-(void)setupForLogEntry:(LogEntry*) logEntry;
-(void)dateSelected:(NSDate *)date;
-(void)MeterDataEnteredForHobbsStart:(NSNumber*)hobbsStart
                        HobbsEnd:(NSNumber*)hobbsEnd
                        HobbsDuration:(NSNumber*)hobbsDuration
                        TachStart:(NSNumber*)tachStart
                        TachEnd:(NSNumber*)tachEnd
                        TachDuration:(NSNumber*)tachDuration
                        BrokenTach:(BOOL)brokenTach
                        BrokenHobbs:(BOOL)brokenHobbs;

-(void)projectDataSelectedFor:(Project*)project;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hobbsLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (weak, nonatomic) IBOutlet UILabel *projectStaticLabel;
@property (weak, nonatomic) id<NewLogbookDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *hobbsStaticLabel;
@property (weak, nonatomic) IBOutlet UILabel *crewLabel;
@property (weak, nonatomic) IBOutlet UILabel *crew2Label;
@property (weak, nonatomic) IBOutlet UILabel *Crew3Label;
@property (weak, nonatomic) IBOutlet UILabel *crew4Label;

@property (weak, nonatomic) IBOutlet UILabel *routeStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeEndLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property BOOL readOnly;

@property NSManagedObjectContext *managedObjectContext;
@property LogEntry* logEntry;




@end
