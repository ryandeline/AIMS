//
//  Project.h
//  flightlog
//
//  Created by Chris Frederick on 10/24/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * areaName;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *logEntries;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;

@end
