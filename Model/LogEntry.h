//
//  LogEntry.h
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "LogEntry.h"
#import "Aircraft.h"
#import "Airport.h"
#import "Crew.h"
#import "MaintanceSchedule.h"
#import "Project.h"
#import "Sensor.h"

@interface LogEntry : NSManagedObject

+ (LogEntry *) getLatestLogEntryForAircraft:(NSString *)tailNumber inManagedObjectContext:(NSManagedObjectContext *)context;

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * maintenanceType;
@property (nonatomic, retain) NSString * nonFlightReason;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * hobbsDuration;
@property (nonatomic, retain) NSNumber * hobbsEnd;
@property (nonatomic, retain) NSNumber * hobbsStart;
@property (nonatomic, retain) NSDate * logDate;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * syncInd;
@property (nonatomic, retain) NSNumber * tachDuration;
@property (nonatomic, retain) NSNumber * tachEnd;
@property (nonatomic, retain) NSNumber * tachStart;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString *tailNumber;
@property (nonatomic, retain) NSString *toICAO;
@property (nonatomic, retain) NSString *fromICAO;
@property (nonatomic, retain) NSString *logType;
@property (nonatomic, retain) MaintanceSchedule *maintanceSchedule;
@property (nonatomic, retain) Crew *pilot;
@property (nonatomic, retain) Crew *pilot2;
@property (nonatomic, retain) Crew *pilot3;
@property (nonatomic, retain) Crew *pilot4;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) Sensor *sensor;

@end
