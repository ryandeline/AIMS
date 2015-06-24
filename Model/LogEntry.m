//
//  LogEntry.m
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "LogEntry.h"



@implementation LogEntry

@dynamic comment;
@dynamic maintenanceType;
@dynamic nonFlightReason;
@dynamic createdAt;
@dynamic hobbsDuration;
@dynamic hobbsEnd;
@dynamic hobbsStart;
@dynamic logDate;
@dynamic objectId;
@dynamic syncInd;
@dynamic tachDuration;
@dynamic tachEnd;
@dynamic tachStart;
@dynamic updatedAt;
@dynamic tailNumber;
@dynamic toICAO;
@dynamic fromICAO;
@dynamic logType;
@dynamic maintanceSchedule;
@dynamic pilot;
@dynamic pilot2;
@dynamic pilot3;
@dynamic pilot4;
@dynamic project;
@dynamic sensor;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    [self setLogDate:[NSDate date]];
}

+ (LogEntry *) getLatestLogEntryForAircraft:(NSString *)tailNumber inManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];
    
    // Results should be in descending order of timeStamp.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"logDate" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    //Results should only be for the currently active tailNumber
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tailNumber = %@ and logType = %@", tailNumber, @"flight"];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if([results count] > 0)
        return (LogEntry*)[results objectAtIndex:0];
    else
        return nil;
}

@end
