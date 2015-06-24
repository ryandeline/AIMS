//
//  Crew.h
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface Crew : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * crewName;
@property (nonatomic, retain) NSString * empStatus;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *pilot1LogEntries;
@property (nonatomic, retain) NSSet *pilot2LogEntries;
@property (nonatomic, retain) NSSet *pilot3LogEntries;
@property (nonatomic, retain) NSSet *pilot4LogEntries;
@end

@interface Crew (CoreDataGeneratedAccessors)

- (void)addPilot1LogEntriesObject:(LogEntry *)value;
- (void)removePilot1LogEntriesObject:(LogEntry *)value;
- (void)addPilot1LogEntries:(NSSet *)values;
- (void)removePilot1LogEntries:(NSSet *)values;

- (void)addPilot2LogEntriesObject:(LogEntry *)value;
- (void)removePilot2LogEntriesObject:(LogEntry *)value;
- (void)addPilot2LogEntries:(NSSet *)values;
- (void)removePilot2LogEntries:(NSSet *)values;

- (void)addPilot3LogEntriesObject:(LogEntry *)value;
- (void)removePilot3LogEntriesObject:(LogEntry *)value;
- (void)addPilot3LogEntries:(NSSet *)values;
- (void)removePilot3LogEntries:(NSSet *)values;

- (void)addPilot4LogEntriesObject:(LogEntry *)value;
- (void)removePilot4LogEntriesObject:(LogEntry *)value;
- (void)addPilot4LogEntries:(NSSet *)values;
- (void)removePilot4LogEntries:(NSSet *)values;

@end
