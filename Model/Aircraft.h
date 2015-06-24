//
//  Aircraft.h
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface Aircraft : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * tailNumber;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic) BOOL brokenHobbs;
@property (nonatomic) BOOL brokenTach;

@end

