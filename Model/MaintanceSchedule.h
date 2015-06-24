//
//  MaintanceSchedule.h
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface MaintanceSchedule : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * dateInterval;
@property (nonatomic, retain) NSString * maintanceDesc;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * scheduleType;
@property (nonatomic, retain) NSDate * seedDate;
@property (nonatomic, retain) NSNumber * seedTach;
@property (nonatomic, retain) NSNumber * tachInteravl;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *logEntries;
@end

@interface MaintanceSchedule (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;

@end
