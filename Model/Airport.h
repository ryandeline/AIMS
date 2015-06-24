//
//  Airport.h
//  flightlog
//
//  Created by Chris Frederick on 10/22/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface Airport : NSManagedObject

@property (nonatomic, retain) NSString * icao;
@property (nonatomic, retain) NSString * iata;
@property (nonatomic, retain) NSString * airportLocation;
@property (nonatomic, retain) NSString * airportName;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * updatedAt;

@end
